import pytest

from app.config import settings

FAR_FUTURE_MS = 4102444800000  # 2100-01-01


async def _register(client, email):
    r = await client.post(
        "/api/v1/auth/register", json={"email": email, "password": "secret123"}
    )
    token = r.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}
    me = await client.get("/api/v1/auth/me", headers=headers)
    return me.json()["id"], headers


@pytest.mark.asyncio
async def test_webhook_grants_premium(client, monkeypatch):
    monkeypatch.setattr(settings, "REVENUECAT_WEBHOOK_AUTH", "secret-token")
    uid, headers = await _register(client, "pay@fisly.app")

    me = await client.get("/api/v1/auth/me", headers=headers)
    assert me.json()["plan"] == "free"

    wh = await client.post(
        "/api/v1/billing/webhook",
        headers={"Authorization": "secret-token"},
        json={"event": {
            "type": "INITIAL_PURCHASE",
            "app_user_id": uid,
            "expiration_at_ms": FAR_FUTURE_MS,
        }},
    )
    assert wh.status_code == 200, wh.text

    me2 = await client.get("/api/v1/auth/me", headers=headers)
    assert me2.json()["plan"] == "premium"
    assert me2.json()["premium_expires_at"] is not None


@pytest.mark.asyncio
async def test_webhook_expiration_revokes_premium(client, monkeypatch):
    monkeypatch.setattr(settings, "REVENUECAT_WEBHOOK_AUTH", "secret-token")
    uid, headers = await _register(client, "exp@fisly.app")

    await client.post(
        "/api/v1/billing/webhook",
        headers={"Authorization": "secret-token"},
        json={"event": {"type": "RENEWAL", "app_user_id": uid, "expiration_at_ms": FAR_FUTURE_MS}},
    )
    await client.post(
        "/api/v1/billing/webhook",
        headers={"Authorization": "secret-token"},
        json={"event": {"type": "EXPIRATION", "app_user_id": uid}},
    )

    me = await client.get("/api/v1/auth/me", headers=headers)
    assert me.json()["plan"] == "free"
    assert me.json()["premium_expires_at"] is None


@pytest.mark.asyncio
async def test_webhook_rejects_bad_auth(client, monkeypatch):
    monkeypatch.setattr(settings, "REVENUECAT_WEBHOOK_AUTH", "secret-token")
    r = await client.post(
        "/api/v1/billing/webhook",
        headers={"Authorization": "wrong"},
        json={"event": {"type": "INITIAL_PURCHASE", "app_user_id": "x"}},
    )
    assert r.status_code == 401


@pytest.mark.asyncio
async def test_webhook_unknown_user_ignored(client, monkeypatch):
    monkeypatch.setattr(settings, "REVENUECAT_WEBHOOK_AUTH", "secret-token")
    r = await client.post(
        "/api/v1/billing/webhook",
        headers={"Authorization": "secret-token"},
        json={"event": {
            "type": "INITIAL_PURCHASE",
            "app_user_id": "00000000-0000-0000-0000-000000000000",
            "expiration_at_ms": FAR_FUTURE_MS,
        }},
    )
    assert r.status_code == 200
    assert r.json()["status"] == "ignored"
