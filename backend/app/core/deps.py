import uuid as uuid_lib
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from jose import JWTError
from app.database import get_db
from app.core.security import decode_token
from app.models.user import User
from app.models.revoked_token import RevokedToken

bearer = HTTPBearer()


async def _is_revoked(jti: str | None, db: AsyncSession) -> bool:
    if not jti:
        return False
    result = await db.execute(select(RevokedToken.id).where(RevokedToken.jti == jti))
    return result.scalar_one_or_none() is not None


async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(bearer),
    db: AsyncSession = Depends(get_db),
) -> User:
    token = credentials.credentials
    try:
        payload = decode_token(token)
        if payload.get("type") != "access":
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")
        user_id = payload.get("sub")
        jti = payload.get("jti")
    except JWTError:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Could not verify token")

    if await _is_revoked(jti, db):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Token has been revoked")

    try:
        user_uuid = uuid_lib.UUID(str(user_id))
    except (ValueError, TypeError):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid user ID")

    result = await db.execute(select(User).where(User.id == user_uuid))
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="User not found")
    return user
