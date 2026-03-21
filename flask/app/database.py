import logging
import sqlite3

logger = logging.getLogger(__name__)
_db_path: str | None = None


def _set_pragmas(conn: sqlite3.Connection) -> None:
    conn.execute("PRAGMA journal_mode = WAL")
    conn.execute("PRAGMA synchronous = NORMAL")
    conn.execute("PRAGMA busy_timeout = 5000")
    conn.execute("PRAGMA foreign_keys = ON")


_SCHEMA = """
CREATE TABLE IF NOT EXISTS example (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
"""


def init_db(db_path: str) -> None:
    global _db_path
    _db_path = db_path
    conn = _get_conn()
    conn.executescript(_SCHEMA)
    conn.commit()
    conn.close()
    logger.info("Database initialized at %s", db_path)


def _get_conn() -> sqlite3.Connection:
    if _db_path is None:
        raise RuntimeError("Database not initialized. Call init_db() first.")
    conn = sqlite3.connect(_db_path)
    conn.row_factory = sqlite3.Row
    _set_pragmas(conn)
    return conn


def create_example(name: str) -> dict:
    conn = _get_conn()
    cursor = conn.execute(
        "INSERT INTO example (name) VALUES (?) RETURNING id, name, created_at",
        (name,),
    )
    row = cursor.fetchone()
    conn.commit()
    result = dict(row)
    conn.close()
    return result


def get_example(example_id: int) -> dict | None:
    conn = _get_conn()
    cursor = conn.execute(
        "SELECT id, name, created_at FROM example WHERE id = ?",
        (example_id,),
    )
    row = cursor.fetchone()
    conn.close()
    return dict(row) if row else None


def list_examples(limit: int = 50, offset: int = 0) -> list[dict]:
    conn = _get_conn()
    cursor = conn.execute(
        "SELECT id, name, created_at FROM example ORDER BY id DESC LIMIT ? OFFSET ?",
        (limit, offset),
    )
    rows = cursor.fetchall()
    conn.close()
    return [dict(r) for r in rows]
