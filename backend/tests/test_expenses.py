import pytest


async def _make_user(client, email="exp@fisly.app"):
    r = await client.post("/api/v1/auth/register", json={
        "email": email, "password": "secret123",
    })
    return r.json()["access_token"]


@pytest.mark.asyncio
async def test_create_and_list_expense(client):
    token = await _make_user(client)
    headers = {"Authorization": f"Bearer {token}"}

    # Liste başta boş
    r = await client.get("/api/v1/expenses", headers=headers)
    assert r.status_code == 200
    assert r.json() == []

    # Harcama oluştur
    r2 = await client.post("/api/v1/expenses", headers=headers, json={
        "amount": "123.45",
        "merchant": "Migros",
        "note": "Haftalık alışveriş",
    })
    assert r2.status_code in (200, 201), r2.text

    # Listeye gelmeli
    r3 = await client.get("/api/v1/expenses", headers=headers)
    assert r3.status_code == 200
    items = r3.json()
    assert len(items) == 1
    assert items[0]["merchant"] == "Migros"


@pytest.mark.asyncio
async def test_expense_isolation_between_users(client):
    token_a = await _make_user(client, "a@fisly.app")
    token_b = await _make_user(client, "b@fisly.app")

    await client.post("/api/v1/expenses",
        headers={"Authorization": f"Bearer {token_a}"},
        json={"amount": "100", "merchant": "A market"})

    r = await client.get("/api/v1/expenses",
        headers={"Authorization": f"Bearer {token_b}"})
    assert r.status_code == 200
    assert r.json() == []
