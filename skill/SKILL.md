---
name: new-project
description: >
  Orchestrate the full CP7 project lifecycle from idea to running service.
  Triggers on: "new project", "build something new", "I have an idea",
  "start a project", "new-project.sh", or pasting a scaffold command.
---

# New Project \u2014 Full Lifecycle Orchestrator

Coordinate the full process from idea to running, monitored, version-controlled
service. Hand off to specialized skills and tools at the right moments.

**Your job:** Run the checklist. Enforce the gates. Challenge assumptions.
Research before recommending. Hand off to the right tool at the right time.

Read [references/checklist.md](references/checklist.md) for the full checklist.
Read [references/tools.md](references/tools.md) for bridge tools and Notion IDs.

## Roles
- **CHRIS** = Decisions, ideas, approval at every gate, final say.
- **ADVISOR** (you) = Specs, challenge assumptions, research, orchestrate.
- **AGENT** (Claude Code) = Write code, run tests. No decisions.

## Phases
0. **Idea** (Chris): One sentence.
1. **Decide** (Chris+Advisor): Wizard + GATE: challenge answers.
2. **Scaffold** (Advisor): `new-project.sh <n> <port> --yes`
3. **Spec** (Chris->Advisor->Chris): Write SPEC.md. RESEARCH RULE. GATE: approve.
3b. **Tech Verify** (Advisor): Verify every dep against current docs.
4. **Build** (Agent->Advisor->Chris): RESEARCH RULE. GATE: adversarial review. GATE: spot check.
5. **Wire Up** (Advisor->Chris): Cloudflare, dashboard, bridge.
6. **Git** (Advisor): Init, push to ratpackcp7/<n>.
7. **Record** (Advisor): Notion + Context Engine + To-Do Tracker.
8. **Maintain** (ongoing): Backups, monitoring, friction log.

## Gates
| Gate | After | What |
|------|-------|------|
| Lane check | Phase 1 | Advisor challenges, Chris confirms |
| Spec approval | Phase 3 | Chris reads and approves SPEC.md |
| Tech verify | Phase 3b | Advisor verifies deps |
| Adversarial review | Phase 4 | Advisor reviews build vs spec |
| Spot check | Phase 4 | Chris verifies running app |

## Research Rules (non-negotiable)
Every library, API, integration, config format, Docker image, CLI flag, or
package version MUST be verified via web search. Never rely on training data.

## How to Start
1. Ask for one-sentence idea
2. Wizard or chat questions
3. system_preflight.sh
4. Challenge (gate)
5. Scaffold with --yes
6. Spec -> tech verify -> approve
7. Build -> review -> approve
8. Wire, git, record

Do NOT skip phases. Do NOT proceed past a gate without Chris's approval.
