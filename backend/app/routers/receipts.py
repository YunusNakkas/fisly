import logging
import uuid
from datetime import date, datetime
from decimal import Decimal, InvalidOperation
from uuid import UUID
from fastapi import APIRouter, Depends, HTTPException, Request, UploadFile, File
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.database import get_db
from app.core.deps import get_current_user
from app.core.limiter import limiter
from app.models.user import User
from app.models.receipt import Receipt, ReceiptStatus
from app.models.receipt_item import ReceiptItem
from app.models.expense import Expense
from app.models.category import Category
from app.schemas.receipt import ReceiptScanResponse, ReceiptResponse, ReceiptUpdate, ScannedExpense
from app.services import ocr_service
from app.services.quota_service import has_quota, quota_limit_for, quota_used_this_month
from app.services.storage_service import get_storage

router = APIRouter(prefix="/receipts", tags=["receipts"])
logger = logging.getLogger("fisly")

ALLOWED_MIME = {"image/jpeg", "image/png", "image/webp", "image/heic"}
MAX_SIZE_MB = 5


async def _to_response(receipt: Receipt) -> ReceiptResponse:
    """Receipt ORM -> response, image_url'i süreli presigned URL'e çevirerek."""
    resp = ReceiptResponse.model_validate(receipt)
    resp.image_url = await get_storage().presigned_url(receipt.image_url)
    return resp


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
@limiter.limit("20/minute")
async def scan_receipt(
    request: Request,
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    if file.content_type not in ALLOWED_MIME:
        raise HTTPException(status_code=400, detail="You can only upload JPEG, PNG, WebP or HEIC files.")

    if not await has_quota(current_user, db):
        limit = quota_limit_for(current_user)
        used = await quota_used_this_month(current_user, db)
        raise HTTPException(
            status_code=429,
            detail=f"Your monthly receipt limit is full ({used}/{limit}). You can upgrade to Premium or try again next month.",
        )

    image_bytes = await file.read()
    if len(image_bytes) > MAX_SIZE_MB * 1024 * 1024:
        raise HTTPException(status_code=400, detail=f"File size cannot exceed {MAX_SIZE_MB}MB.")

    content_type = file.content_type or "image/jpeg"
    ext = (file.filename or "").rsplit(".", 1)[-1] or "jpg"
    storage_key = f"receipts/{current_user.id}/{uuid.uuid4()}.{ext}"
    await get_storage().upload(storage_key, image_bytes, content_type)

    ocr_data = await ocr_service.parse_receipt(image_bytes, content_type)

    merchant = ocr_data.get("merchant")
    total_amount = _parse_decimal(ocr_data.get("total_amount"))
    receipt_date = _parse_date(ocr_data.get("receipt_date"))
    items = ocr_data.get("items", [])

    status = ReceiptStatus.parsed if total_amount is not None else ReceiptStatus.failed

    receipt = Receipt(
        user_id=current_user.id,
        image_url=storage_key,
        raw_ocr_data=ocr_data,
        merchant=merchant,
        total_amount=total_amount,
        receipt_date=receipt_date,
        status=status,
    )
    db.add(receipt)
    await db.flush()

    # Load categories to map category names to UUIDs.
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
            item_name = item.get("name") or "Item"
            item_qty = _parse_decimal(item.get("quantity"))
            item_unit = _parse_decimal(item.get("unit_price"))
            item_total = _parse_decimal(item.get("total"))
            item_amount = item_total or item_unit or Decimal("0")
            cat_name: str | None = item.get("category")
            matched_cat: Category | None = cat_map.get(cat_name.lower()) if cat_name else None

            db.add(ReceiptItem(
                receipt_id=receipt.id,
                name=item_name,
                quantity=item_qty,
                unit_price=item_unit,
                total=item_total,
                category_id=matched_cat.id if matched_cat else None,
            ))

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
        # If the item list is empty, create one expense.
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
            name=merchant or "Expense",
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
    return [await _to_response(r) for r in result.scalars().all()]


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
        raise HTTPException(status_code=404, detail="Receipt not found")
    return await _to_response(receipt)


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
        raise HTTPException(status_code=404, detail="Receipt not found")

    for field, value in body.model_dump(exclude_none=True).items():
        setattr(receipt, field, value)
    receipt.status = ReceiptStatus.manual

    await db.commit()
    await db.refresh(receipt)
    return await _to_response(receipt)


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
        raise HTTPException(status_code=404, detail="Receipt not found")

    try:
        await get_storage().delete(receipt.image_url)
    except Exception:
        logger.exception("Failed to delete receipt object from storage: %s", receipt.image_url)

    await db.delete(receipt)
    await db.commit()
