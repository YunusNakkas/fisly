from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from sqlalchemy.exc import IntegrityError
from decimal import Decimal
from datetime import date, datetime
from uuid import UUID

from app.database import get_db
from app.core.deps import get_current_user
from app.models.user import User
from app.models.budget import Budget, BudgetPeriod
from app.models.expense import Expense
from app.models.category import Category
from app.schemas.budget import (
    BudgetCreate,
    BudgetUpdate,
    BudgetResponse,
    BudgetProgress,
)

router = APIRouter(prefix="/budgets", tags=["budgets"])


def _period_range(period: BudgetPeriod, ref: date) -> tuple[datetime, datetime]:
    if period == BudgetPeriod.monthly:
        start = datetime(ref.year, ref.month, 1)
        end = (
            datetime(ref.year, ref.month + 1, 1)
            if ref.month < 12
            else datetime(ref.year + 1, 1, 1)
        )
    else:  # weekly - starts on Monday
        weekday = ref.weekday()
        start_d = ref.fromordinal(ref.toordinal() - weekday)
        start = datetime(start_d.year, start_d.month, start_d.day)
        end_d = start_d.fromordinal(start_d.toordinal() + 7)
        end = datetime(end_d.year, end_d.month, end_d.day)
    return start, end


@router.get("", response_model=list[BudgetResponse])
async def list_budgets(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(Budget).where(Budget.user_id == current_user.id)
    )
    return result.scalars().all()


@router.post("", response_model=BudgetResponse, status_code=201)
async def create_budget(
    body: BudgetCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    budget = Budget(
        user_id=current_user.id,
        category_id=body.category_id,
        amount=body.amount,
        period=body.period,
        starts_on=body.starts_on or date.today(),
    )
    db.add(budget)
    try:
        await db.commit()
    except IntegrityError:
        await db.rollback()
        raise HTTPException(
            status_code=409,
            detail="A budget is already defined for this category",
        )
    await db.refresh(budget)
    return budget


@router.patch("/{budget_id}", response_model=BudgetResponse)
async def update_budget(
    budget_id: UUID,
    body: BudgetUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(Budget).where(
            Budget.id == budget_id, Budget.user_id == current_user.id
        )
    )
    budget = result.scalar_one_or_none()
    if not budget:
        raise HTTPException(status_code=404, detail="Budget not found")

    for field, value in body.model_dump(exclude_none=True).items():
        setattr(budget, field, value)

    await db.commit()
    await db.refresh(budget)
    return budget


@router.delete("/{budget_id}", status_code=204)
async def delete_budget(
    budget_id: UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(Budget).where(
            Budget.id == budget_id, Budget.user_id == current_user.id
        )
    )
    budget = result.scalar_one_or_none()
    if not budget:
        raise HTTPException(status_code=404, detail="Budget not found")
    await db.delete(budget)
    await db.commit()


@router.get("/progress", response_model=list[BudgetProgress])
async def budgets_progress(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    today = date.today()
    result = await db.execute(
        select(Budget).where(Budget.user_id == current_user.id)
    )
    budgets = result.scalars().all()

    out: list[BudgetProgress] = []
    for b in budgets:
        start_dt, end_dt = _period_range(b.period, today)
        q = select(func.coalesce(func.sum(Expense.amount), 0)).where(
            Expense.user_id == current_user.id,
            Expense.spent_at >= start_dt,
            Expense.spent_at < end_dt,
        )
        if b.category_id is not None:
            q = q.where(Expense.category_id == b.category_id)

        spent_res = await db.execute(q)
        spent: Decimal = spent_res.scalar_one() or Decimal(0)

        category_name: str | None = None
        if b.category_id is not None:
            cat_res = await db.execute(
                select(Category.name).where(Category.id == b.category_id)
            )
            category_name = cat_res.scalar_one_or_none()

        amount = Decimal(b.amount)
        remaining = amount - spent
        percent = float(spent / amount * 100) if amount > 0 else 0.0

        out.append(
            BudgetProgress(
                budget_id=b.id,
                category_id=b.category_id,
                category_name=category_name,
                amount=amount,
                spent=spent,
                remaining=remaining,
                percent=round(percent, 2),
            )
        )
    return out
