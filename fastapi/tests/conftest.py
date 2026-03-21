import os
import pytest
from httpx import ASGITransport, AsyncClient

os.environ["DATABASE_PATH"] = "./data/test.db"

from src.main import app


@pytest.fixture
async def client():
    async with AsyncClient(
        transport=ASGITransport(app=app),
        base_url="http://test",
    ) as ac:
        yield ac


@pytest.fixture(autouse=True)
async def setup_db():
    from src.database import init_db, close_db
    os.makedirs("./data", exist_ok=True)
    await init_db()
    yield
    await close_db()
    for f in ["./data/test.db", "./data/test.db-wal", "./data/test.db-shm"]:
        if os.path.exists(f):
            os.remove(f)
