# Checklist v2 - Role Assignments

| Phase | Chris | Advisor | Agent |
|-------|-------|---------|-------|
| 0 Idea | Write sentence | - | - |
| 1 Decide | Wizard + confirm | Challenge + ports | - |
| 2 Scaffold | Approve | Run script | - |
| 3 Spec | Requirements + approve | Write SPEC, research | - |
| 3b Verify | Re-approve if changed | Verify every dep | - |
| 4 Build | Spot-check | Review vs spec | Write code, tests |
| 5 Wire | Verify browser | CF + dashboard | - |
| 6 Git | - | Init + push | - |
| 7 Record | Say save | Notion + CE | - |
| 8 Maintain | Monitor | Diagnose | - |

## Phase 3b: Technical Verification
After spec approved, before build:
1. List every dep/integration in spec
2. Search current docs for each
3. Flag compatibility issues or gotchas
4. Revise spec if needed (re-approve)

## Phase 4: Adversarial Review
After build, rate findings:
- MUST FIX: breaks functionality or security
- SHOULD FIX: best practice, log if deferred
- NICE TO HAVE: future improvement

Checks: requirement coverage, test coverage, validation,
error handling, SQL location, hardcoded values, security.

## Convention: all SQL in database.py
Routes call db.get_thing(id), never cursor.execute().
Makes SQLite->Postgres migration a single-file change.
