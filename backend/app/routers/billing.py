import logging
from datetime import datetime, timezone
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, Request, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.config import settings
from app.database import get_db
from app.models.user import User, Plan

logger = logging.getLogger("fisly")

router = APIRouter(prefix="/billing", tags=["billing"])

# RevenueCat olay türleri → premium ver / al
_GRANT_EVENTS = {
    "INITIAL_PURCHASE",
    "RENEWAL",
    "UNCANCELLATION",
    "PRODUCT_CHANGE",
    "NON_RENEWING_PURCHASE",
}
_REVOKE_EVENTS = {"EXPIRATION"}
# CANCELLATION = otomatik yenileme kapatıldı; abonelik bitene (EXPIRATION) kadar premium kalır.


def _ms_to_dt(ms: int | None) -> datetime | None:
    if not ms:
        return None
    return datetime.fromtimestamp(ms / 1000, tz=timezone.utc)


@router.post("/webhook", status_code=status.HTTP_200_OK)
async def revenuecat_webhook(request: Request, db: AsyncSession = Depends(get_db)):
    """RevenueCat abonelik olaylarını işler, kullanıcı planını günceller.

    Kimlik doğrulama: RevenueCat dashboard'da ayarlanan Authorization header,
    REVENUECAT_WEBHOOK_AUTH ile eşleşmeli.
    """
    if not settings.REVENUECAT_WEBHOOK_AUTH:
        raise HTTPException(status_code=503, detail="Billing webhook is not configured")

    if request.headers.get("authorization") != settings.REVENUECAT_WEBHOOK_AUTH:
        raise HTTPException(status_code=401, detail="Invalid webhook authorization")

    payload = await request.json()
    event = payload.get("event", {})
    event_type = event.get("type")
    app_user_id = event.get("app_user_id")

    # app_user_id mobil tarafta Purchases.logIn ile set edilen kullanıcı UUID'sidir.
    try:
        user_uuid = UUID(str(app_user_id))
    except (ValueError, TypeError):
        logger.info("Webhook %s: non-UUID app_user_id %r, ignored", event_type, app_user_id)
        return {"status": "ignored"}

    result = await db.execute(select(User).where(User.id == user_uuid))
    user = result.scalar_one_or_none()
    if not user:
        logger.warning("Webhook %s: user %s not found", event_type, user_uuid)
        return {"status": "ignored"}

    if event_type in _GRANT_EVENTS:
        user.plan = Plan.premium
        user.premium_expires_at = _ms_to_dt(event.get("expiration_at_ms"))
        logger.info("Premium granted to %s (event %s)", user_uuid, event_type)
    elif event_type in _REVOKE_EVENTS:
        user.plan = Plan.free
        user.premium_expires_at = None
        logger.info("Premium revoked from %s (event %s)", user_uuid, event_type)
    else:
        # CANCELLATION, BILLING_ISSUE, TEST, SUBSCRIBER_ALIAS vb. → plan değişmez.
        return {"status": "ignored", "event": event_type}

    await db.commit()
    return {"status": "ok", "event": event_type}
