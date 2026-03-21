def test_health(client):
    resp = client.get("/health")
    assert resp.status_code == 200
    data = resp.get_json()
    assert data["status"] == "ok"
    assert data["service"] == "PROJECT_NAME"


def test_create_and_get_example(client):
    resp = client.post("/api/v1/examples", json={"name": "test-item"})
    assert resp.status_code == 200
    created = resp.get_json()
    assert created["name"] == "test-item"
    assert "id" in created
    resp = client.get(f"/api/v1/examples/{created["id"]}")
    assert resp.status_code == 200
    assert resp.get_json()["name"] == "test-item"


def test_list_examples(client):
    client.post("/api/v1/examples", json={"name": "a"})
    client.post("/api/v1/examples", json={"name": "b"})
    resp = client.get("/api/v1/examples")
    assert resp.status_code == 200
    assert len(resp.get_json()) >= 2


def test_get_missing_example(client):
    resp = client.get("/api/v1/examples/99999")
    assert resp.status_code == 404


def test_create_missing_name(client):
    resp = client.post("/api/v1/examples", json={})
    assert resp.status_code == 400
