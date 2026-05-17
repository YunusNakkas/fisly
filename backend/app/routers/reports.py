import csv
import io
from fastapi import APIRouter, Depends, Query, Response
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from decimal import Decimal
from datetime import date
from uuid import UUID
from app.database import get_db
from app.core.deps import get_current_user
from app.models.user import User
from app.models.expense import Expense
from app.models.category import Category
from pydantic import BaseModel

router = APIRouter(prefix="/reports", tags=["reports"])


class CategoryBreakdown(BaseModel):
    category_id: UUID | None
    name: str
    icon: str
    color: str
    total: Decimal
    count: int


class SummaryResponse(BaseModel):
    year: int
    month: int
    total: Decimal
    expense_count: int
    category_breakdown: list[CategoryBreakdown]


class MonthTrend(BaseModel):
    year: int
    month: int
    total: Decimal
    count: int


@router.get("/summary", response_model=SummaryResponse)
async def get_summary(
    year: int = Query(default=None),
    month: int = Query(default=None),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    today = date.today()
    year = year or today.year
    month = month or today.month

    from datetime import datetime
    from_dt = datetime(year, month, 1)
    to_dt = datetime(year, month + 1, 1) if month < 12 else datetime(year + 1, 1, 1)

    # Total + count
    total_result = await db.execute(
        select(func.coalesce(func.sum(Expense.amount), 0), func.count(Expense.id))
        .where(
            Expense.user_id == current_user.id,
            Expense.spent_at >= from_dt,
            Expense.spent_at < to_dt,
        )
    )
    total_amount, expense_count = total_result.one()

    # Category breakdown
    breakdown_result = await db.execute(
        select(
            Category.id,
            Category.name,
            Category.icon,
            Category.color,
            func.coalesce(func.sum(Expense.amount), 0).label("total"),
            func.count(Expense.id).label("count"),
        )
        .join(Expense, Expense.category_id == Category.id, isouter=True)
        .where(
            Category.id.in_(
                select(Expense.category_id)
                .where(
                    Expense.user_id == current_user.id,
                    Expense.spent_at >= from_dt,
                    Expense.spent_at < to_dt,
                    Expense.category_id.isnot(None),
                )
                .distinct()
            )
        )
        .group_by(Category.id)
        .order_by(func.sum(Expense.amount).desc())
    )
    rows = breakdown_result.all()

    breakdown = [
        CategoryBreakdown(
            category_id=r.id,
            name=r.name,
            icon=r.icon,
            color=r.color,
            total=r.total,
            count=r.count,
        )
        for r in rows
    ]

    return SummaryResponse(
        year=year,
        month=month,
        total=total_amount,
        expense_count=expense_count,
        category_breakdown=breakdown,
    )


@router.get("/trends", response_model=list[MonthTrend])
async def get_trends(
    months: int = Query(default=6, ge=2, le=12),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    from datetime import datetime

    today = date.today()
    result: list[MonthTrend] = []

    for i in range(months - 1, -1, -1):
        m = today.month - i
        y = today.year
        while m <= 0:
            m += 12
            y -= 1

        from_dt = datetime(y, m, 1)
        to_dt = datetime(y, m + 1, 1) if m < 12 else datetime(y + 1, 1, 1)

        row = await db.execute(
            select(
                func.coalesce(func.sum(Expense.amount), Decimal("0")),
                func.count(Expense.id),
            ).where(
                Expense.user_id == current_user.id,
                Expense.spent_at >= from_dt,
                Expense.spent_at < to_dt,
            )
        )
        total, count = row.one()
        result.append(MonthTrend(year=y, month=m, total=total, count=count))

    return result


@router.get("/export.csv")
async def export_month_csv(
    year: int = Query(default=None),
    month: int = Query(default=None),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    from datetime import datetime

    today = date.today()
    year = year or today.year
    month = month or today.month

    from_dt = datetime(year, month, 1)
    to_dt = datetime(year, month + 1, 1) if month < 12 else datetime(year + 1, 1, 1)

    rows = await db.execute(
        select(Expense, Category.name)
        .join(Category, Expense.category_id == Category.id, isouter=True)
        .where(
            Expense.user_id == current_user.id,
            Expense.spent_at >= from_dt,
            Expense.spent_at < to_dt,
        )
        .order_by(Expense.spent_at.desc())
    )

    out = io.StringIO()
    writer = csv.writer(out)
    writer.writerow(["date", "merchant", "category", "note", "amount", "currency"])
    for expense, category_name in rows.all():
        writer.writerow(
            [
                expense.spent_at.isoformat(),
                expense.merchant or "",
                category_name or "",
                expense.note or "",
                str(expense.amount),
                expense.currency,
            ]
        )

    filename = f"fisly-{year}-{month:02d}.csv"
    return Response(
        content=out.getvalue(),
        media_type="text/csv; charset=utf-8",
        headers={"Content-Disposition": f'attachment; filename="{filename}"'},
    )
