from pydantic import BaseModel, Field
from decimal import Decimal
from datetime import date
from uuid import UUID
from app.models.subscription import Period, SubscriptionStatus


class SubscriptionCreate(BaseModel):
    name: str = Field(min_length=1, max_length=255)
    amount: Decimal = Field(gt=0)
    currency: str = "TRY"
    period: Period
    start_date: date
    next_billing_date: date
    category_id: UUID | None = None


class SubscriptionUpdate(BaseModel):
    name: str | None = Field(default=None, min_length=1, max_length=255)
    amount: Decimal | None = Field(default=None, gt=0)
    next_billing_date: date | None = None
    category_id: UUID | None = None


class SubscriptionResponse(BaseModel):
    id: UUID
    user_id: UUID
    category_id: UUID | None
    name: str
    amount: Decimal
    currency: str
    period: Period
    start_date: date
    next_billing_date: date
    status: SubscriptionStatus

    class Config:
        from_attributes = True
