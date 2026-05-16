import logging
import os
from logging.handlers import RotatingFileHandler
from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from app.database import get_db
from app.core.deps import get_current_user
from app.models.user import User
from app.models.feedback import Feedback
from app.schemas.feedback import FeedbackCreate, FeedbackResponse

os.makedirs("logs/feedbacks", exist_ok=True)

_fb_handler = RotatingFileHandler(
    "logs/feedbacks/feedbacks.log", maxBytes=5 * 1024 * 1024, backupCount=3, encoding="utf-8"
)
_fb_handler.setFormatter(logging.Formatter(
    "%(asctime)s | %(message)s", datefmt="%Y-%m-%d %H:%M:%S"
))

logger = logging.getLogger("fisly.feedback")
logger.addHandler(_fb_handler)
logger.propagate = False

router = APIRouter(prefix="/feedback", tags=["feedback"])


@router.post("", response_model=FeedbackResponse, status_code=201)
async def submit_feedback(
    body: FeedbackCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    fb = Feedback(
        user_id=current_user.id,
        kind=body.kind,
        subject=body.subject,
        message=body.message,
    )
    db.add(fb)
    await db.commit()
    await db.refresh(fb)
    logger.info(
        "YENİ GERİ BİLDİRİM | kullanıcı: %s | tür: %s | başlık: %s | mesaj: %s",
        current_user.email,
        body.kind,
        body.subject,
        body.message,
    )
    return fb
