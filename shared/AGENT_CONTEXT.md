# PROJECT_NAME — Agent Context

## Project
- **Name:** PROJECT_NAME
- **Port:** PROJECT_PORT
- **URL:** https://PROJECT_NAME.cp7.dev
- **Framework:** FRAMEWORK_NAME
- **Database:** SQLite WAL at ./data/PROJECT_NAME.db
- **Deploy:** DEPLOY_TARGET

## Rules
- ALL database queries go in database.py — never in route handlers
- Run pytest tests/ -v after every change
- Check health: curl http://localhost:PROJECT_PORT/health
- Read SPEC.md before starting any task
- Update TASKS.md when completing work
