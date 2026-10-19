import pytest


async def _make_user(client, email):
    r = await client.post("/api/v1/auth/register", json={
        "email": email, "password": "secret123",
    })
    return r.json()["access_token"]


async def _a_category_id(client, headers):
    r = await client.post("/api/v1/categories", headers=headers, json={
        "name": "Market", "icon": "cart", "color": "#6366f1",
    })
    assert r.status_code in (200, 201), r.text
    return r.json()["id"]


@pytest.mark.asyncio
async def test_summary_breakdown_matches_total_and_is_user_scoped(client):
    token_a = await _make_user(client, "rep_a@fisly.app")
    headers_a = {"Authorization": f"Bearer {token_a}"}
    cat_id = await _a_category_id(client, headers_a)

    # A kullanıcısı aynı kategoriye iki harcama
    for amount in ("100.00", "50.50"):
        r = await client.post("/api/v1/expenses", headers=headers_a, json={
            "amount": amount, "category_id": cat_id, "merchant": "Migros",
        })
        assert r.status_code == 201, r.text

    # B kullanıcısı aynı kategoriye harcama (sızmamalı)
    token_b = await _make_user(client, "rep_b@fisly.app")
    headers_b = {"Authorization": f"Bearer {token_b}"}
    await client.post("/api/v1/expenses", headers=headers_b, json={
        "amount": "999.00", "category_id": cat_id, "merchant": "Başka",
    })

    r = await client.get("/api/v1/reports/summary", headers=headers_a)
    assert r.status_code == 200, r.text
    data = r.json()

    # Toplam yalnızca A'nın harcamaları
    assert float(data["total"]) == pytest.approx(150.50)
    assert data["expense_count"] == 2

    # Breakdown toplamı genel toplama eşit olmalı (bug: tüm kullanıcıları topluyordu)
    breakdown_sum = sum(float(c["total"]) for c in data["category_breakdown"])
    assert breakdown_sum == pytest.approx(float(data["total"]))

    # Kategori satırı da yalnızca A'nın 2 harcamasını saymalı
    cat_row = next(c for c in data["category_breakdown"] if c["category_id"] == cat_id)
    assert cat_row["count"] == 2
    assert float(cat_row["total"]) == pytest.approx(150.50)
