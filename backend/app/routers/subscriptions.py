from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from uuid import UUID
from app.database import get_db
from app.core.deps import get_current_user
from app.models.user import User
from app.models.subscription import Subscription, SubscriptionStatus
from app.schemas.subscription import SubscriptionCreate, SubscriptionUpdate, SubscriptionResponse

router = APIRouter(prefix="/subscriptions", tags=["subscriptions"])


@router.get("", response_model=list[SubscriptionResponse])
async def list_subscriptions(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(Subscription)
        .where(Subscription.user_id == current_user.id)
        .order_by(Subscription.next_billing_date.asc())
    )
    return result.scalars().all()


@router.post("", response_model=SubscriptionResponse, status_code=201)
async def create_subscription(
    body: SubscriptionCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    sub = Subscription(
        user_id=current_user.id,
        name=body.name,
        amount=body.amount,
        currency=body.currency,
        period=body.period,
        start_date=body.start_date,
        next_billing_date=body.next_billing_date,
        category_id=body.category_id,
    )
    db.add(sub)
    await db.commit()
    await db.refresh(sub)
    return sub


@router.patch("/{sub_id}", response_model=SubscriptionResponse)
async def update_subscription(
    sub_id: UUID,
    body: SubscriptionUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(Subscription).where(
            Subscription.id == sub_id, Subscription.user_id == current_user.id
        )
    )
    sub = result.scalar_one_or_none()
    if not sub:
        raise HTTPException(status_code=404, detail="Subscription not found")

    for field, value in body.model_dump(exclude_none=True).items():
        setattr(sub, field, value)

    await db.commit()
    await db.refresh(sub)
    return sub


@router.delete("/{sub_id}", status_code=204)
async def delete_subscription(
    sub_id: UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(Subscription).where(
            Subscription.id == sub_id, Subscription.user_id == current_user.id
        )
    )
    sub = result.scalar_one_or_none()
    if not sub:
        raise HTTPException(status_code=404, detail="Subscription not found")
    await db.delete(sub)
    await db.commit()


@router.post("/{sub_id}/cancel", response_model=SubscriptionResponse)
async def cancel_subscription(
    sub_id: UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(Subscription).where(
            Subscription.id == sub_id, Subscription.user_id == current_user.id
        )
    )
    sub = result.scalar_one_or_none()
    if not sub:
        raise HTTPException(status_code=404, detail="Subscription not found")
    sub.status = SubscriptionStatus.cancelled
    await db.commit()
    await db.refresh(sub)
    return sub
