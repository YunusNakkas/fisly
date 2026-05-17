import pytest


@pytest.mark.asyncio
async def test_health_endpoint(client):
    r = await client.get("/health")
    assert r.status_code == 200
    assert r.json() == {"status": "ok"}


@pytest.mark.asyncio
async def test_root_endpoint(client):
    r = await client.get("/")
    assert r.status_code == 200
    assert "Fişly" in r.json()["message"]
