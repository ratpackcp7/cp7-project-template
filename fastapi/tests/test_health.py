import pytest


@pytest.mark.asyncio
async def test_health(client):
    resp = await client.get("/health")
    assert resp.status_code == 200
    data = resp.json()
    assert data["status"] == "ok"
    assert data["service"] == "PROJECT_NAME"


@pytest.mark.asyncio
async def test_create_and_get_example(client):
    resp = await client.post("/api/v1/examples", json={"name": "test-item"})
    assert resp.status_code == 200
    created = resp.json()
    assert created["name"] == "test-item"
    assert "id" in created
    resp = await client.get(f"/api/v1/examples/{created['id']}")
    assert resp.status_code == 200
    assert resp.json()["name"] == "test-item"


@pytest.mark.asyncio
async def test_list_examples(client):
    await client.post("/api/v1/examples", json={"name": "a"})
    await client.post("/api/v1/examples", json={"name": "b"})
    resp = await client.get("/api/v1/examples")
    assert resp.status_code == 200
    assert len(resp.json()) >= 2


@pytest.mark.asyncio
async def test_get_missing_example(client):
    resp = await client.get("/api/v1/examples/99999")
    assert resp.status_code == 404
