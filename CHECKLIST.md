# CP7 New Project Checklist v2
### Roles, review gates, and research-first rules

**Roles:**
- **YOU** = Chris. Decisions, ideas, approval gates, final say.
- **ADVISOR** = Claude (chat). Designs specs, challenges assumptions, researches.
- **AGENT** = Claude Code / relay. Writes code, runs tests, deploys. No decisions.

**Symbols:** YOU | ADVISOR | AGENT | GATE (approval required) | RESEARCH (no training data)

---

## Phase 0: Idea (YOU)
- Write one sentence: This is a ___ for ___ that does ___

## Phase 1: Decide (YOU + ADVISOR)
- YOU: Run wizard at assets.cp7.dev/wizard.html
- GATE: ADVISOR challenges your answers (lane match? overbuilding?)
- YOU: Confirm or revise
- ADVISOR: Check ports via system_preflight.sh

## Phase 2: Scaffold (ADVISOR runs)
- Dry-run: new-project.sh <n> <port> --dry-run
- Run for real
- Verify health endpoint

## Phase 3: Spec (YOU requirements -> ADVISOR writes -> YOU approves)
- YOU: Describe what it does, who uses it, constraints
- ADVISOR: Write SPEC.md (overview, data model, API, business logic, open questions)
- RESEARCH: Any library/API/integration in the spec -> search current docs first
- Optional: Run through Prompt Refiner
- GATE: YOU read and approve SPEC.md

## Phase 4: Build (AGENT writes -> ADVISOR reviews -> YOU approves)
- RESEARCH: Every import, package, Docker image, config format -> search current docs
- AGENT or ADVISOR: Implement database.py -> routes -> tests
- All SQL in database.py, never in route handlers
- GATE: Adversarial review (ADVISOR reviews build vs spec):
  - Every requirement has implementation + test?
  - Validation on all inputs?
  - Error handling present?
  - Security issues?
  - Findings rated: MUST FIX / SHOULD FIX / NICE TO HAVE
- Fix MUST FIX items
- YOU: Decide on SHOULD FIX (now or log to issues)
- GATE: YOU spot-checks running app

## Phase 5: Wire Up (ADVISOR executes -> YOU verifies)
- Cloudflare route
- Dashboard tile
- Bridge allowlist
- YOU: Verify in browser

## Phase 6: Git (ADVISOR executes)
- git init, commit, create repo, push

## Phase 7: Record (ADVISOR on save command)
- Notion Session Logs + Context Engine + To-Do Tracker
- Update TASKS.md

## Phase 8: Maintain (ongoing)
- Restic backups, dashboard monitoring, GitHub issues log

---

## Role summary

| Phase | YOU | ADVISOR | AGENT |
|-------|-----|---------|-------|
| 0 Idea | Write sentence | - | - |
| 1 Decide | Wizard + confirm | Challenge + ports | - |
| 2 Scaffold | Approve | Run script | - |
| 3 Spec | Requirements + approve | Write SPEC, research | - |
| 4 Build | Spot-check, SHOULD FIX | Review vs spec, research | Write code, tests |
| 5 Wire | Verify browser | CF + dashboard + bridge | - |
| 6 Git | - | Init + push | - |
| 7 Record | Say save | Notion + CE + tracker | - |
| 8 Maintain | Monitor | Diagnose | - |

## Gates
1. Lane check (after Phase 1) - Advisor challenges, you confirm
2. Spec approval (after Phase 3) - You read and approve SPEC.md
3. Adversarial review (after Phase 4) - Advisor reviews build vs spec
4. Spot check (after Phase 4 fixes) - You verify running app

## Research rules
- Writing spec: search docs for any library/API/integration referenced
- Building: search docs for every import, package, config format
- Debugging: root cause research first, never generic troubleshooting
