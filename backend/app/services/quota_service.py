from datetime import datetime, timezone
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession
from app.config import settings
from app.models.receipt import Receipt
from app.models.user import User, Plan


def _month_start_utc() -> datetime:
    now = datetime.now(timezone.utc)
    return datetime(now.year, now.month, 1, tzinfo=timezone.utc)


def quota_limit_for(user: User) -> int | None:
    """Return monthly receipt quota for the user, or None for unlimited (premium)."""
    if user.plan == Plan.premium:
        return None
    return settings.FREE_RECEIPT_QUOTA


async def quota_used_this_month(user: User, db: AsyncSession) -> int:
    result = await db.execute(
        select(func.count(Receipt.id)).where(
            Receipt.user_id == user.id,
            Receipt.created_at >= _month_start_utc(),
        )
    )
    return int(result.scalar_one() or 0)


async def has_quota(user: User, db: AsyncSession) -> bool:
    limit = quota_limit_for(user)
    if limit is None:
        return True
    used = await quota_used_this_month(user, db)
    return used < limit
