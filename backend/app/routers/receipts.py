import uuid
import os
import aiofiles
from datetime import date, datetime
from decimal import Decimal, InvalidOperation
from uuid import UUID
from fastapi import APIRouter, Depends, HTTPException, UploadFile, File
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.database import get_db
from app.core.deps import get_current_user
from app.models.user import User
from app.models.receipt import Receipt, ReceiptStatus
from app.models.expense import Expense
from app.models.category import Category
from app.schemas.receipt import ReceiptScanResponse, ReceiptResponse, ReceiptUpdate, ScannedExpense
from app.services import ocr_service
from app.services.quota_service import has_quota, quota_limit_for, quota_used_this_month

router = APIRouter(prefix="/receipts", tags=["receipts"])

UPLOAD_DIR = "uploads"
ALLOWED_MIME = {"image/jpeg", "image/png", "image/webp", "image/heic"}
MAX_SIZE_MB = 5


def _parse_decimal(value) -> Decimal | None:
    if value is None:
        return None
    try:
        return Decimal(str(value))
    except InvalidOperation:
        return None


def _parse_date(value: str | None) -> date | None:
    if not value:
        return None
    try:
        return date.fromisoformat(value)
    except ValueError:
        return None


@router.post("/scan", response_model=ReceiptScanResponse, status_code=201)
async def scan_receipt(
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    if file.content_type not in ALLOWED_MIME:
        raise HTTPException(status_code=400, detail="Sadece JPEG, PNG, WebP veya HEIC dosya yükleyebilirsiniz.")

    if not await has_quota(current_user, db):
        limit = quota_limit_for(current_user)
        used = await quota_used_this_month(current_user, db)
        raise HTTPException(
            status_code=429,
            detail=f"Aylık fiş limitiniz doldu ({used}/{limit}). Premium'a geçebilir veya gelecek ay tekrar deneyebilirsiniz.",
        )

    image_bytes = await file.read()
    if len(image_bytes) > MAX_SIZE_MB * 1024 * 1024:
        raise HTTPException(status_code=400, detail=f"Dosya boyutu {MAX_SIZE_MB}MB'ı geçemez.")

    ext = (file.filename or "").rsplit(".", 1)[-1] or "jpg"
    filename = f"{uuid.uuid4()}.{ext}"
    os.makedirs(UPLOAD_DIR, exist_ok=True)
    filepath = os.path.join(UPLOAD_DIR, filename)
    async with aiofiles.open(filepath, "wb") as f:
        await f.write(image_bytes)

    ocr_data = await ocr_service.parse_receipt(image_bytes, file.content_type or "image/jpeg")

    merchant = ocr_data.get("merchant")
    total_amount = _parse_decimal(ocr_data.get("total_amount"))
    receipt_date = _parse_date(ocr_data.get("receipt_date"))
    items = ocr_data.get("items", [])

    status = ReceiptStatus.parsed if total_amount is not None else ReceiptStatus.failed

    receipt = Receipt(
        user_id=current_user.id,
        image_url=f"/uploads/{filename}",
        raw_ocr_data=ocr_data,
        merchant=merchant,
        total_amount=total_amount,
        receipt_date=receipt_date,
        status=status,
    )
    db.add(receipt)
    await db.flush()

    # Kategori adı → UUID eşlemesi için sistem kategorilerini yükle
    cat_result = await db.execute(
        select(Category).where(
            (Category.user_id == current_user.id) | (Category.user_id.is_(None))
        )
    )
    categories = cat_result.scalars().all()
    cat_map: dict[str, Category] = {c.name.lower(): c for c in categories}

    spent_at = datetime.combine(receipt_date, datetime.min.time()) if receipt_date else datetime.utcnow()

    scanned_expenses: list[ScannedExpense] = []

    if items:
        for item in items:
            item_name = item.get("name") or "Ürün"
            item_amount = _parse_decimal(item.get("total")) or _parse_decimal(item.get("unit_price")) or Decimal("0")
            cat_name: str | None = item.get("category")
            matched_cat: Category | None = cat_map.get(cat_name.lower()) if cat_name else None

            expense = Expense(
                user_id=current_user.id,
                receipt_id=receipt.id,
                amount=item_amount,
                merchant=merchant,
                note=item_name,
                category_id=matched_cat.id if matched_cat else None,
                spent_at=spent_at,
            )
            db.add(expense)
            await db.flush()

            scanned_expenses.append(ScannedExpense(
                expense_id=expense.id,
                name=item_name,
                amount=item_amount,
                category_id=matched_cat.id if matched_cat else None,
                category_name=matched_cat.name if matched_cat else None,
            ))
    else:
        # Ürün listesi boşsa tek harcama oluştur
        expense = Expense(
            user_id=current_user.id,
            receipt_id=receipt.id,
            amount=total_amount or Decimal("0"),
            merchant=merchant,
            spent_at=spent_at,
        )
        db.add(expense)
        await db.flush()

        scanned_expenses.append(ScannedExpense(
            expense_id=expense.id,
            name=merchant or "Harcama",
            amount=total_amount or Decimal("0"),
            category_id=None,
            category_name=None,
        ))

    await db.commit()

    return ReceiptScanResponse(
        receipt_id=receipt.id,
        merchant=merchant,
        total_amount=total_amount,
        receipt_date=receipt_date,
        status=status,
        expenses=scanned_expenses,
    )


@router.get("", response_model=list[ReceiptResponse])
async def list_receipts(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(Receipt)
        .where(Receipt.user_id == current_user.id)
        .order_by(Receipt.created_at.desc())
    )
    return result.scalars().all()


@router.get("/{receipt_id}", response_model=ReceiptResponse)
async def get_receipt(
    receipt_id: UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(Receipt).where(Receipt.id == receipt_id, Receipt.user_id == current_user.id)
    )
    receipt = result.scalar_one_or_none()
    if not receipt:
        raise HTTPException(status_code=404, detail="Fiş bulunamadı")
    return receipt


@router.patch("/{receipt_id}", response_model=ReceiptResponse)
async def update_receipt(
    receipt_id: UUID,
    body: ReceiptUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(Receipt).where(Receipt.id == receipt_id, Receipt.user_id == current_user.id)
    )
    receipt = result.scalar_one_or_none()
    if not receipt:
        raise HTTPException(status_code=404, detail="Fiş bulunamadı")

    for field, value in body.model_dump(exclude_none=True).items():
        setattr(receipt, field, value)
    receipt.status = ReceiptStatus.manual

    await db.commit()
    await db.refresh(receipt)
    return receipt


@router.delete("/{receipt_id}", status_code=204)
async def delete_receipt(
    receipt_id: UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(Receipt).where(Receipt.id == receipt_id, Receipt.user_id == current_user.id)
    )
    receipt = result.scalar_one_or_none()
    if not receipt:
        raise HTTPException(status_code=404, detail="Fiş bulunamadı")

    await db.delete(receipt)
    await db.commit()
