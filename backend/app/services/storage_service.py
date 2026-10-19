"""Fiş görselleri için storage soyutlaması.

Dev'de local disk (`uploads/`), production'da Cloudflare R2 (private bucket).
`STORAGE_BACKEND` env'i ile seçilir. Object'ler key ile saklanır; istemciye
süreli presigned (R2) ya da statik (local) URL döner.
"""
import asyncio
import logging
import os
from abc import ABC, abstractmethod
from functools import lru_cache

import aiofiles

from app.config import settings

logger = logging.getLogger("fisly")

LOCAL_UPLOAD_DIR = "uploads"


class Storage(ABC):
    @abstractmethod
    async def upload(self, key: str, data: bytes, content_type: str) -> None: ...

    @abstractmethod
    async def presigned_url(self, key: str, expires: int | None = None) -> str: ...

    @abstractmethod
    async def delete(self, key: str) -> None: ...


class LocalStorage(Storage):
    """Dosyaları `uploads/` altına yazar, StaticFiles mount'u servis eder."""

    async def upload(self, key: str, data: bytes, content_type: str) -> None:
        path = os.path.join(LOCAL_UPLOAD_DIR, key)
        os.makedirs(os.path.dirname(path), exist_ok=True)
        async with aiofiles.open(path, "wb") as f:
            await f.write(data)

    async def presigned_url(self, key: str, expires: int | None = None) -> str:
        # Statik servis; süre yok.
        return f"/{LOCAL_UPLOAD_DIR}/{key}"

    async def delete(self, key: str) -> None:
        path = os.path.join(LOCAL_UPLOAD_DIR, key)
        try:
            os.remove(path)
        except FileNotFoundError:
            pass


class R2Storage(Storage):
    """Cloudflare R2 (S3-uyumlu). boto3 sync olduğu için to_thread ile sarılır."""

    def __init__(self) -> None:
        import boto3
        from botocore.config import Config

        self._bucket = settings.R2_BUCKET
        self._default_expire = settings.R2_URL_EXPIRE_SECONDS
        self._client = boto3.client(
            "s3",
            endpoint_url=f"https://{settings.R2_ACCOUNT_ID}.r2.cloudflarestorage.com",
            aws_access_key_id=settings.R2_ACCESS_KEY_ID,
            aws_secret_access_key=settings.R2_SECRET_ACCESS_KEY,
            region_name="auto",
            config=Config(signature_version="s3v4"),
        )

    async def upload(self, key: str, data: bytes, content_type: str) -> None:
        await asyncio.to_thread(
            self._client.put_object,
            Bucket=self._bucket,
            Key=key,
            Body=data,
            ContentType=content_type,
        )

    async def presigned_url(self, key: str, expires: int | None = None) -> str:
        return await asyncio.to_thread(
            self._client.generate_presigned_url,
            "get_object",
            Params={"Bucket": self._bucket, "Key": key},
            ExpiresIn=expires or self._default_expire,
        )

    async def delete(self, key: str) -> None:
        await asyncio.to_thread(
            self._client.delete_object, Bucket=self._bucket, Key=key
        )


@lru_cache
def get_storage() -> Storage:
    if settings.STORAGE_BACKEND == "r2":
        return R2Storage()
    return LocalStorage()
