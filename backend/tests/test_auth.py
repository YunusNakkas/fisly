import pytest


@pytest.mark.asyncio
async def test_register_and_login(client):
    r = await client.post("/api/v1/auth/register", json={
        "email": "test@fisly.app",
        "password": "secret123",
        "full_name": "Test User",
    })
    assert r.status_code == 201, r.text
    data = r.json()
    assert "access_token" in data
    assert "refresh_token" in data

    # Aynı email tekrar register → 400
    r2 = await client.post("/api/v1/auth/register", json={
        "email": "test@fisly.app",
        "password": "secret123",
    })
    assert r2.status_code == 400

    # Login
    r3 = await client.post("/api/v1/auth/login", json={
        "email": "test@fisly.app",
        "password": "secret123",
    })
    assert r3.status_code == 200
    assert "access_token" in r3.json()


@pytest.mark.asyncio
async def test_login_wrong_password(client):
    await client.post("/api/v1/auth/register", json={
        "email": "u@fisly.app", "password": "right123",
    })
    r = await client.post("/api/v1/auth/login", json={
        "email": "u@fisly.app", "password": "wrong",
    })
    assert r.status_code == 401


@pytest.mark.asyncio
async def test_me_requires_auth(client):
    r = await client.get("/api/v1/auth/me")
    # HTTPBearer header yokken 403 döner, geçersiz token'da 401 döner
    assert r.status_code in (401, 403)


@pytest.mark.asyncio
async def test_me_with_token(client):
    r = await client.post("/api/v1/auth/register", json={
        "email": "me@fisly.app", "password": "secret123",
    })
    token = r.json()["access_token"]
    r2 = await client.get("/api/v1/auth/me", headers={"Authorization": f"Bearer {token}"})
    assert r2.status_code == 200
    assert r2.json()["email"] == "me@fisly.app"


@pytest.mark.asyncio
async def test_forgot_password_does_not_leak_existence(client):
    # Kullanıcı yokken de 202 dönmeli (varlık ifşa edilmemeli)
    r = await client.post("/api/v1/auth/forgot-password", json={"email": "nobody@fisly.app"})
    assert r.status_code == 202


@pytest.mark.asyncio
async def test_delete_account(client):
    r = await client.post("/api/v1/auth/register", json={
        "email": "del@fisly.app", "password": "secret123",
    })
    token = r.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    # Hesabı sil
    r2 = await client.delete("/api/v1/auth/me", headers=headers)
    assert r2.status_code == 204, r2.text

    # Aynı email ile tekrar kayıt mümkün olmalı (kullanıcı gerçekten silindi)
    r3 = await client.post("/api/v1/auth/register", json={
        "email": "del@fisly.app", "password": "secret123",
    })
    assert r3.status_code == 201


@pytest.mark.asyncio
async def test_delete_account_requires_auth(client):
    r = await client.delete("/api/v1/auth/me")
    assert r.status_code in (401, 403)


@pytest.mark.asyncio
async def test_refresh_token_rotation(client):
    r = await client.post("/api/v1/auth/register", json={
        "email": "rot@fisly.app", "password": "secret123",
    })
    refresh = r.json()["refresh_token"]

    # İlk refresh çalışır
    r2 = await client.post("/api/v1/auth/refresh", json={"refresh_token": refresh})
    assert r2.status_code == 200

    # Aynı refresh ikinci kez kullanılamaz (rotation)
    r3 = await client.post("/api/v1/auth/refresh", json={"refresh_token": refresh})
    assert r3.status_code == 401
