from pydantic import BaseModel, Field
from decimal import Decimal
from datetime import date
from uuid import UUID
from app.models.budget import BudgetPeriod


class BudgetCreate(BaseModel):
    amount: Decimal = Field(gt=0)
    period: BudgetPeriod = BudgetPeriod.monthly
    category_id: UUID | None = None
    starts_on: date | None = None


class BudgetUpdate(BaseModel):
    amount: Decimal | None = Field(default=None, gt=0)


class BudgetResponse(BaseModel):
    id: UUID
    user_id: UUID
    category_id: UUID | None
    amount: Decimal
    period: BudgetPeriod
    starts_on: date

    class Config:
        from_attributes = True


class BudgetProgress(BaseModel):
    budget_id: UUID
    category_id: UUID | None
    category_name: str | None
    amount: Decimal
    spent: Decimal
    remaining: Decimal
    percent: float
