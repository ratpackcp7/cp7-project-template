import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI, Request, Response

from src.api.routes import router
from src.config import settings

logging.basicConfig(
    level=settings.log_level,
    format="%(asctime)s %(levelname)s %(name)s: %(message)s",
)
logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    from src.database import close_db, init_db

    logger.info("PROJECT_NAME starting up on port %s", settings.port)
    await init_db()
    yield
    await close_db()
    logger.info("PROJECT_NAME shutting down")


app = FastAPI(
    title="PROJECT_NAME",
    description="PROJECT_DESCRIPTION",
    version="0.1.0",
    lifespan=lifespan,
)

app.include_router(router)


@app.get("/health")
async def health():
    return {"status": "ok", "service": "PROJECT_NAME"}


@app.middleware("http")
async def limit_request_size(request: Request, call_next):
    content_length = request.headers.get("content-length")
    if content_length and int(content_length) > settings.max_request_bytes:
        return Response(status_code=413, content="Request too large")
    return await call_next(request)
