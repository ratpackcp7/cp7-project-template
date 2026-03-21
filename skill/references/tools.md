# CP7 Tools Reference

## Bridge scripts (run_script)
- system_preflight.sh - containers, ports, services, disk, memory
- new-project.sh <n> <port> [--framework] [--deploy] [--yes] [--dry-run]
- cf-tunnel.sh add <n>.cp7.dev http://localhost:<port>
- bridge-reload.sh - reload config
- context_save.sh JSON - save to Context Engine
- claude_code_relay.sh "prompt" [max_turns] [budget]
- git_commit.sh - commit and push
- run_ephemeral.sh "command" - one-off shell

## Notion IDs
- Session Logs: 74a9ce9d-e229-48c3-bc0e-25e409496e4b
- To-Do Tracker: c61ee4e3-cdf1-4f36-a1df-e0053557eb9f
- Hub: 31df6863-72de-8132-ae5e-e616c112fbbf

## Context Engine
Save: run_script context_save.sh JSON
Required: summary, decisions[], open_items[], tech_changes[], next_steps[]
Check slugs first: homelab, finance-hub, cba, context-engine, mfd-roster, global

## URLs
- Wizard: https://assets.cp7.dev/wizard.html
- Dashboard: https://dashboard.cp7.dev
- Friction log: github.com/ratpackcp7/cp7-project-template/issues/1
- Template: github.com/ratpackcp7/cp7-project-template

## new-project.sh flags
--framework fastapi|flask (default: fastapi)
--deploy systemd|docker (default: systemd with --yes)
--yes/-y skip prompts (always use via bridge)
--description "..." (default: name)
--no-cloudflare --no-bridge --dry-run
