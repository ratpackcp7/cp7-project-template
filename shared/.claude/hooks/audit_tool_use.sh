#!/usr/bin/env bash
# audit_tool_use.sh — PostToolUse hook (Edit|Write|MultiEdit|Bash), project-local
#
# Appends one JSONL line per tool call to .audit/session-YYYY-MM-DD.jsonl.
# Buckets file edits as planned/side_quest/drift based on SPEC.md scope.
# Bash commands are logged with truncated cmd + exit code.
#
# Buckets:
#   planned    — file matches in_scope
#   side_quest — file matches out_of_scope (allowed despite warning)
#   drift      — file matches neither (not anticipated by SPEC at all)
#   no_spec    — no SPEC.md exists yet
set -euo pipefail

INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty')
[[ -z "$TOOL" ]] && exit 0
[[ -d ".git" ]] || exit 0

mkdir -p .audit
LOG=".audit/session-$(date +%Y-%m-%d).jsonl"
TS=$(date -Iseconds)
SESSION=$(echo "$INPUT" | jq -r '.session_id // "unknown"')

bucket_for() {
  local rel="$1" bucket="drift" pat
  [[ -f "SPEC.md" ]] || { echo "no_spec"; return; }
  while IFS= read -r pat; do
    [[ -z "$pat" ]] && continue
    # shellcheck disable=SC2254
    case "$rel" in $pat) echo "planned"; return ;; esac
  done < <(awk '/^in_scope:/{f=1;next} /^[a-z_]+:/{if(f)exit} f && /^[[:space:]]*-[[:space:]]*"/{sub(/^[[:space:]]*-[[:space:]]*"/,"");sub(/".*/,"");print}' SPEC.md)
  while IFS= read -r pat; do
    [[ -z "$pat" ]] && continue
    # shellcheck disable=SC2254
    case "$rel" in $pat) echo "side_quest"; return ;; esac
  done < <(awk '/^out_of_scope:/{f=1;next} /^[a-z_]+:/{if(f)exit} f && /^[[:space:]]*-[[:space:]]*"/{sub(/^[[:space:]]*-[[:space:]]*"/,"");sub(/".*/,"");print}' SPEC.md)
  echo "$bucket"
}

case "$TOOL" in
  Edit|Write|MultiEdit)
    FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty')
    [[ -z "$FILE" ]] && exit 0
    REL="${FILE#$(pwd)/}"
    BUCKET=$(bucket_for "$REL")
    jq -nc --arg ts "$TS" --arg s "$SESSION" --arg t "$TOOL" --arg f "$REL" --arg b "$BUCKET" \
      '{ts:$ts, session:$s, tool:$t, file:$f, bucket:$b}' >> "$LOG"
    ;;
  Bash)
    CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty' | head -c 200 | tr '\n' ' ')
    EXIT=$(echo "$INPUT" | jq -r '.tool_response.exit_code // .tool_response.code // 0' 2>/dev/null || echo 0)
    [[ -z "$EXIT" || "$EXIT" == "null" ]] && EXIT=0
    jq -nc --arg ts "$TS" --arg s "$SESSION" --arg t "$TOOL" --arg c "$CMD" --argjson e "$EXIT" \
      '{ts:$ts, session:$s, tool:$t, cmd:$c, exit:$e}' >> "$LOG" 2>/dev/null || true
    ;;
esac

exit 0
