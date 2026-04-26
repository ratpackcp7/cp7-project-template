# AGENTS.md — PROJECT_NAME

PROJECT_DESCRIPTION. FRAMEWORK_NAME, deployed via DEPLOY_TARGET.

## Before You Start

- Read `SPEC.md` for full feature spec and design decisions
- Read `AGENT_CONTEXT.md` for coding conventions
- Read `HANDOFF.md` for current work status

## Key Facts
- **Port**: PROJECT_PORT | **URL**: PROJECT_NAME.cp7.dev
- **Stack**: FRAMEWORK_NAME
- **Deploy**: DEPLOY_TARGET
- **Health**: `curl http://localhost:PROJECT_PORT/health`
- **Tests**: `pytest tests/ -v`

## Architecture
- `src/database.py` — ALL SQL lives here, never inline SQL elsewhere
- `src/api/routes.py` — HTTP handlers under `/api`
- `src/main.py` — app entry point

## Dev Commands
```bash
# TODO: fill in after build phase
```

## Active Work

See `HANDOFF.md` for current work status and next steps.

## Rules
- All SQL in database.py
- Tests must pass before committing
- Update HANDOFF.md before finishing any work session
