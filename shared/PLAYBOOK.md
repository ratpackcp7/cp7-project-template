# PROJECT_NAME — Playbook

## Status: Phase 1

## Build Order
1. [ ] Core data model + database
2. [ ] API endpoints (CRUD)
3. [ ] Tests for all endpoints
4. [ ] Deploy (systemd/Docker)
5. [ ] Cloudflare route + dashboard tile

## Verify
```bash
curl http://localhost:PROJECT_PORT/health
pytest tests/ -v
```
