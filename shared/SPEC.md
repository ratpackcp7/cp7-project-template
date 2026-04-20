# PROJECT_NAME — Specification

## Definition of Done
<!-- The literal end-game. 3-5 bullets max. When all are true, this project ships.
     Do not delete bullets as scope evolves; mark them done. -->
- [ ] Core feature(s) implemented per Requirements
- [ ] Tests pass: `pytest tests/ -v`
- [ ] Deployed and reachable at https://PROJECT_NAME.cp7.dev
- [ ] HANDOFF.md reflects current state
- [ ] README.md explains what it does and how to run it

## Scope
<!-- Glob patterns. Used by .claude/hooks/scope_guard.sh + audit_tool_use.sh.
     - Files matching in_scope  → logged as "planned"  (silent allow)
     - Files matching out_of_scope → WARN to agent + logged as "side_quest"
     - Files matching neither → logged as "drift" (not in spec at all)
     Format: one pattern per line. Bash case-glob semantics (* spans /). -->
in_scope:
  - "src/*"
  - "tests/*"
  - "*.md"
  - ".env*"
  - "requirements.txt"
  - "Dockerfile"
  - "docker-compose.yml"
out_of_scope:
  - "data/*"
  - "venv/*"
  - "*.db"
  - "*.sqlite*"
  - "migrations/*.sql"
  - ".audit/*"

## Overview
PROJECT_DESCRIPTION

## Requirements
1. ...

## Architecture
- **Framework:** FRAMEWORK_NAME
- **Database:** SQLite (WAL mode)
- **Deploy:** DEPLOY_TARGET
- **Port:** PROJECT_PORT
- **URL:** https://PROJECT_NAME.cp7.dev

## Data Model

## API Endpoints

## Open Questions
