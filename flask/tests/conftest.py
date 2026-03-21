import os
import pytest

os.environ["DATABASE_PATH"] = "./data/test.db"

from app import create_app


@pytest.fixture
def client():
    app = create_app()
    app.config["TESTING"] = True
    with app.test_client() as client:
        yield client


@pytest.fixture(autouse=True)
def cleanup():
    os.makedirs("./data", exist_ok=True)
    yield
    for f in ["./data/test.db", "./data/test.db-wal", "./data/test.db-shm"]:
        if os.path.exists(f):
            os.remove(f)
