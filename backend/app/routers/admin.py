from fastapi import APIRouter, Depends, HTTPException, Header
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from app.database import get_db
from app.models.feedback import Feedback
from app.models.user import User
from app.config import settings

router = APIRouter(prefix="/admin", tags=["admin"])


def verify_admin(x_admin_token: str = Header(...)):
    if x_admin_token != settings.ADMIN_TOKEN:
        raise HTTPException(status_code=403, detail="Yetkisiz")


@router.get("/feedbacks")
async def list_feedbacks(
    db: AsyncSession = Depends(get_db),
    _: None = Depends(verify_admin),
):
    result = await db.execute(
        select(Feedback, User.email)
        .join(User, Feedback.user_id == User.id)
        .order_by(Feedback.created_at.desc())
    )
    rows = result.all()
    return [
        {
            "id": str(fb.id),
            "user_email": email,
            "kind": fb.kind,
            "subject": fb.subject,
            "message": fb.message,
            "created_at": fb.created_at.isoformat(),
        }
        for fb, email in rows
    ]


@router.get("/stats")
async def stats(
    db: AsyncSession = Depends(get_db),
    _: None = Depends(verify_admin),
):
    user_count = await db.scalar(select(func.count()).select_from(User))
    feedback_count = await db.scalar(select(func.count()).select_from(Feedback))
    return {"users": user_count, "feedbacks": feedback_count}
