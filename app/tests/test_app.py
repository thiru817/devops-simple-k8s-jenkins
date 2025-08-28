import importlib

def get_client():
    app_module = importlib.import_module("app")
    app = getattr(app_module, "app")
    return app.test_client()

def test_health():
    client = get_client()
    resp = client.get("/health")
    assert resp.status_code == 200
    assert resp.data.decode("utf-8") == "ok"

def test_root():
    client = get_client()
    resp = client.get("/")
    assert resp.status_code == 200
    data = resp.get_json()
    assert "message" in data
