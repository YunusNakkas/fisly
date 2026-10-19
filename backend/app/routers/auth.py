import secrets
import hashlib
import logging
import uuid
from datetime import datetime, timedelta, timezone
from fastapi import APIRouter, Depends, HTTPException, Request, UploadFile, File, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, delete
from app.database import get_db
from app.models.user import User
from app.models.password_reset import PasswordReset
from app.models.revoked_token import RevokedToken
from app.models.expense import Expense
from app.models.receipt import Receipt
from app.models.subscription import Subscription
from app.models.budget import Budget
from app.models.feedback import Feedback
from app.models.category import Category
from app.services.storage_service import get_storage
from app.schemas.auth import (
    RegisterRequest,
    LoginRequest,
    TokenResponse,
    RefreshRequest,
    UserResponse,
    UpdateProfileRequest,
    ForgotPasswordRequest,
    ResetPasswordRequest,
)
from app.core.security import hash_password, verify_password, create_access_token, create_refresh_token, decode_token
from app.core.deps import get_current_user
from app.core.limiter import limiter
from app.services.quota_service import quota_limit_for, quota_used_this_month
from app.services import email_service
from jose import JWTError

logger = logging.getLogger("fisly")

PASSWORD_RESET_EXPIRY_MIN = 30


def _hash_reset_token(token: str) -> str:
    return hashlib.sha256(token.encode("utf-8")).hexdigest()


async def _user_response(user: User, db: AsyncSession) -> UserResponse:
    avatar_url = (
        await get_storage().presigned_url(user.avatar_url) if user.avatar_url else None
    )
    return UserResponse(
        id=user.id,
        email=user.email,
        full_name=user.full_name,
        avatar_url=avatar_url,
        plan=user.plan.value if hasattr(user.plan, "value") else str(user.plan),
        premium_expires_at=user.premium_expires_at,
        quota_used=await quota_used_this_month(user, db),
        quota_limit=quota_limit_for(user),
    )


router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/register", response_model=TokenResponse, status_code=status.HTTP_201_CREATED)
async def register(body: RegisterRequest, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(User).where(User.email == body.email))
    if result.scalar_one_or_none():
        raise HTTPException(status_code=400, detail="This email is already registered")

    user = User(
        email=body.email,
        password_hash=hash_password(body.password),
        full_name=body.full_name,
    )
    db.add(user)
    await db.commit()
    await db.refresh(user)

    return TokenResponse(
        access_token=create_access_token(str(user.id)),
        refresh_token=create_refresh_token(str(user.id)),
    )


@router.post("/login", response_model=TokenResponse)
@limiter.limit("10/minute")
async def login(request: Request, body: LoginRequest, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(User).where(User.email == body.email))
    user = result.scalar_one_or_none()

    if not user or not verify_password(body.password, user.password_hash):
        raise HTTPException(status_code=401, detail="Incorrect email or password")

    return TokenResponse(
        access_token=create_access_token(str(user.id)),
        refresh_token=create_refresh_token(str(user.id)),
    )


@router.post("/refresh", response_model=TokenResponse)
async def refresh(body: RefreshRequest, db: AsyncSession = Depends(get_db)):
    try:
        payload = decode_token(body.refresh_token)
        if payload.get("type") != "refresh":
            raise HTTPException(status_code=401, detail="Invalid refresh token")
        user_id = payload.get("sub")
        jti = payload.get("jti")
        exp_ts = payload.get("exp")
    except JWTError:
        raise HTTPException(status_code=401, detail="Could not verify token")

    if jti:
        result = await db.execute(select(RevokedToken.id).where(RevokedToken.jti == jti))
        if result.scalar_one_or_none():
            raise HTTPException(status_code=401, detail="Refresh token has been revoked")

        # Refresh token rotation: revoke the old token
        db.add(RevokedToken(
            jti=jti,
            expires_at=datetime.fromtimestamp(exp_ts, tz=timezone.utc) if exp_ts else datetime.now(timezone.utc),
        ))
        await db.commit()

    return TokenResponse(
        access_token=create_access_token(user_id),
        refresh_token=create_refresh_token(user_id),
    )


@router.post("/logout", status_code=status.HTTP_204_NO_CONTENT)
async def logout(
    body: RefreshRequest | None = None,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Add the refresh token to the revocation list when provided."""
    if body and body.refresh_token:
        try:
            payload = decode_token(body.refresh_token)
            jti = payload.get("jti")
            exp_ts = payload.get("exp")
            if jti:
                db.add(RevokedToken(
                    jti=jti,
                    expires_at=datetime.fromtimestamp(exp_ts, tz=timezone.utc) if exp_ts else datetime.now(timezone.utc),
                ))
                await db.commit()
        except JWTError:
            pass
    logger.info("User %s logged out", current_user.id)
    return None


@router.post("/forgot-password", status_code=status.HTTP_202_ACCEPTED)
@limiter.limit("5/hour")
async def forgot_password(request: Request, body: ForgotPasswordRequest, db: AsyncSession = Depends(get_db)):
    """Create a password reset token.

    Security: do not disclose whether the user exists; always return 202.
    """
    result = await db.execute(select(User).where(User.email == body.email))
    user = result.scalar_one_or_none()

    if user:
        token = secrets.token_urlsafe(32)
        reset = PasswordReset(
            user_id=user.id,
            token_hash=_hash_reset_token(token),
            expires_at=datetime.now(timezone.utc) + timedelta(minutes=PASSWORD_RESET_EXPIRY_MIN),
        )
        db.add(reset)
        await db.commit()
        await email_service.send_password_reset(user.email, token)

    return {"message": "If this email is registered, a reset link has been sent."}


@router.post("/reset-password", status_code=status.HTTP_200_OK)
async def reset_password(body: ResetPasswordRequest, db: AsyncSession = Depends(get_db)):
    token_hash = _hash_reset_token(body.token)
    result = await db.execute(select(PasswordReset).where(PasswordReset.token_hash == token_hash))
    reset = result.scalar_one_or_none()

    if not reset or reset.used:
        raise HTTPException(status_code=400, detail="Invalid or already used token")

    expires_at = reset.expires_at
    if expires_at.tzinfo is None:
        expires_at = expires_at.replace(tzinfo=timezone.utc)
    if expires_at < datetime.now(timezone.utc):
        raise HTTPException(status_code=400, detail="Token has expired")

    if len(body.new_password) < 8:
        raise HTTPException(status_code=400, detail="Password must be at least 8 characters")

    user_result = await db.execute(select(User).where(User.id == reset.user_id))
    user = user_result.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=400, detail="User not found")

    user.password_hash = hash_password(body.new_password)
    reset.used = True
    await db.commit()

    return {"message": "Password updated successfully"}


@router.get("/me", response_model=UserResponse)
async def me(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    return await _user_response(current_user, db)


@router.patch("/me", response_model=UserResponse)
async def update_me(
    body: UpdateProfileRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    if body.new_password:
        if not body.current_password:
            raise HTTPException(status_code=400, detail="Current password is required")
        if not verify_password(body.current_password, current_user.password_hash):
            raise HTTPException(status_code=400, detail="Current password is incorrect")
        current_user.password_hash = hash_password(body.new_password)

    if body.full_name is not None:
        current_user.full_name = body.full_name

    await db.commit()
    await db.refresh(current_user)
    return await _user_response(current_user, db)


AVATAR_ALLOWED_MIME = {"image/jpeg", "image/png", "image/webp", "image/heic"}
AVATAR_MAX_MB = 5


@router.post("/me/avatar", response_model=UserResponse)
async def upload_avatar(
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    if file.content_type not in AVATAR_ALLOWED_MIME:
        raise HTTPException(status_code=400, detail="You can only upload JPEG, PNG, WebP or HEIC files.")

    data = await file.read()
    if len(data) > AVATAR_MAX_MB * 1024 * 1024:
        raise HTTPException(status_code=400, detail=f"File size cannot exceed {AVATAR_MAX_MB}MB.")

    storage = get_storage()
    ext = (file.filename or "").rsplit(".", 1)[-1] or "jpg"
    key = f"avatars/{current_user.id}/{uuid.uuid4()}.{ext}"
    await storage.upload(key, data, file.content_type or "image/jpeg")

    old_key = current_user.avatar_url
    current_user.avatar_url = key
    await db.commit()

    # Eski avatarı depolamadan sil (best-effort).
    if old_key:
        try:
            await storage.delete(old_key)
        except Exception:
            logger.exception("Failed to delete old avatar from storage: %s", old_key)

    await db.refresh(current_user)
    return await _user_response(current_user, db)


@router.delete("/me", status_code=status.HTTP_204_NO_CONTENT)
async def delete_me(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Hesabı ve tüm kişisel verileri kalıcı olarak siler (KVKK silme hakkı / App Store şartı).

    FK cascade olmayan tablolar açık sırayla silinir; fiş görselleri depolamadan kaldırılır.
    """
    uid = current_user.id
    storage = get_storage()

    # Fiş görsellerini depolamadan sil (best-effort).
    keys = await db.execute(select(Receipt.image_url).where(Receipt.user_id == uid))
    for (key,) in keys.all():
        try:
            await storage.delete(key)
        except Exception:
            logger.exception("Failed to delete receipt object during account deletion: %s", key)

    # Çocuk kayıtları FK'yı bozmayacak sırada sil.
    await db.execute(delete(Expense).where(Expense.user_id == uid))
    await db.execute(delete(Receipt).where(Receipt.user_id == uid))  # receipt_items cascade
    await db.execute(delete(Subscription).where(Subscription.user_id == uid))
    await db.execute(delete(Budget).where(Budget.user_id == uid))
    await db.execute(delete(Feedback).where(Feedback.user_id == uid))
    await db.execute(delete(Category).where(Category.user_id == uid))  # sistem kategorileri (user_id NULL) korunur
    await db.execute(delete(User).where(User.id == uid))  # password_resets cascade
    await db.commit()

    logger.info("Account deleted: %s", uid)
    return None
