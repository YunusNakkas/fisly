import os

import pytest

from app.services.storage_service import LocalStorage


@pytest.mark.asyncio
async def test_local_storage_roundtrip(tmp_path, monkeypatch):
    # uploads/ yerine geçici dizinde çalış.
    monkeypatch.chdir(tmp_path)
    storage = LocalStorage()
    key = "receipts/user-1/abc.jpg"
    data = b"fake-image-bytes"

    await storage.upload(key, data, "image/jpeg")
    assert os.path.exists(tmp_path / "uploads" / key)

    url = await storage.presigned_url(key)
    assert url == f"/uploads/{key}"

    await storage.delete(key)
    assert not os.path.exists(tmp_path / "uploads" / key)


@pytest.mark.asyncio
async def test_local_storage_delete_missing_is_noop(tmp_path, monkeypatch):
    monkeypatch.chdir(tmp_path)
    storage = LocalStorage()
    # Olmayan key'i silmek hata fırlatmamalı.
    await storage.delete("receipts/nope/missing.jpg")
