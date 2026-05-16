from pydantic import BaseModel
from decimal import Decimal
from datetime import date, datetime
from uuid import UUID
from app.models.receipt import ReceiptStatus


class ScannedExpense(BaseModel):
    expense_id: UUID
    name: str
    amount: Decimal
    category_id: UUID | None
    category_name: str | None


class ReceiptScanResponse(BaseModel):
    receipt_id: UUID
    merchant: str | None
    total_amount: Decimal | None
    receipt_date: date | None
    status: ReceiptStatus
    expenses: list[ScannedExpense]

    class Config:
        from_attributes = True


class ReceiptResponse(BaseModel):
    id: UUID
    user_id: UUID
    image_url: str
    merchant: str | None
    total_amount: Decimal | None
    receipt_date: date | None
    status: ReceiptStatus
    raw_ocr_data: dict | None
    created_at: datetime

    class Config:
        from_attributes = True


class ReceiptUpdate(BaseModel):
    merchant: str | None = None
    total_amount: Decimal | None = None
    receipt_date: date | None = None
