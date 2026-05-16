from pydantic import BaseModel
from decimal import Decimal
from datetime import datetime
from uuid import UUID


class ExpenseCreate(BaseModel):
    amount: Decimal
    category_id: UUID | None = None
    merchant: str | None = None
    note: str | None = None
    spent_at: datetime | None = None
    currency: str = "TRY"


class ExpenseUpdate(BaseModel):
    amount: Decimal | None = None
    category_id: UUID | None = None
    merchant: str | None = None
    note: str | None = None
    spent_at: datetime | None = None


class ExpenseResponse(BaseModel):
    id: UUID
    user_id: UUID
    category_id: UUID | None
    amount: Decimal
    currency: str
    merchant: str | None
    note: str | None
    spent_at: datetime
    created_at: datetime

    class Config:
        from_attributes = True
