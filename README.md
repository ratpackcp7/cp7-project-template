# cp7-project-template

Project scaffold for CP7 homelab services. Used by `new-project.sh` to bootstrap new FastAPI or Flask projects with standardized structure, database patterns, deployment, and Cloudflare routing.

## Quick start

```bash
new-project.sh my-app 8450 --framework fastapi --deploy systemd
```

## What it does

1. Copies the selected framework template (fastapi or flask)
2. Replaces all placeholders (name, port, description)
3. Creates venv + installs deps (systemd) or builds Docker image
4. Installs and starts the service
5. Registers Cloudflare route (optional)
6. Runs health check

## Stack defaults

| Component | Choice |
|-----------|--------|
| Language | Python 3.12+ |
| API framework | FastAPI (default) or Flask |
| Database | SQLite WAL mode |
| Query layer | Raw SQL in database.py (no ORM) |
| Frontend | HTMX + Jinja2 (Flask) or API-only (FastAPI) |
| Deploy | systemd user service or Docker |
| Tests | pytest |

## Convention: all SQL in database.py

Every template centralizes database access in `database.py`. Route handlers call repository functions like `get_example(id)`, never raw SQL. This makes database migration (SQLite to PostgreSQL) a single-file change.
