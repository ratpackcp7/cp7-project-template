import logging

import aiosqlite

from src.config import settings

logger = logging.getLogger(__name__)

_conn: aiosqlite.Connection | None = None


async def _set_pragmas(conn: aiosqlite.Connection) -> None:
    await conn.execute("PRAGMA journal_mode = WAL")
    await conn.execute("PRAGMA synchronous = NORMAL")
    await conn.execute("PRAGMA busy_timeout = 5000")
    await conn.execute("PRAGMA foreign_keys = ON")


_SCHEMA = """
CREATE TABLE IF NOT EXISTS example (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
"""


async def init_db() -> None:
    global _conn
    _conn = await aiosqlite.connect(settings.database_path)
    _conn.row_factory = aiosqlite.Row
    await _set_pragmas(_conn)
    await _conn.executescript(_SCHEMA)
    await _conn.commit()
    logger.info("Database initialized at %s", settings.database_path)


async def close_db() -> None:
    global _conn
    if _conn:
        await _conn.close()
        _conn = None
        logger.info("Database connection closed")


def get_db() -> aiosqlite.Connection:
    if _conn is None:
        raise RuntimeError("Database not initialized. Call init_db() first.")
    return _conn


async def create_example(name: str) -> dict:
    db = get_db()
    cursor = await db.execute(
        "INSERT INTO example (name) VALUES (?) RETURNING id, name, created_at",
        (name,),
    )
    row = await cursor.fetchone()
    await db.commit()
    return dict(row)


async def get_example(example_id: int) -> dict | None:
    db = get_db()
    cursor = await db.execute(
        "SELECT id, name, created_at FROM example WHERE id = ?",
        (example_id,),
    )
    row = await cursor.fetchone()
    return dict(row) if row else None


async def list_examples(limit: int = 50, offset: int = 0) -> list[dict]:
    db = get_db()
    cursor = await db.execute(
        "SELECT id, name, created_at FROM example ORDER BY id DESC LIMIT ? OFFSET ?",
        (limit, offset),
    )
    rows = await cursor.fetchall()
    return [dict(r) for r in rows]
