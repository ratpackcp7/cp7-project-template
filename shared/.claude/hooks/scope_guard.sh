#!/usr/bin/env bash
# scope_guard.sh — PreToolUse hook (Edit|Write|MultiEdit), project-local
#
# Reads SPEC.md ## Scope block. WARNs (does not block) on out_of_scope edits
# so Claude sees the warning but can proceed when truly needed. Audit hook
# (PostToolUse) will log the result as side_quest for review.
#
# To turn this into a hard block, change the `exit 0` at the end of the
# match branch to `exit 2`.
set -euo pipefail

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty')

[[ -z "$FILE_PATH" ]] && exit 0
[[ -f "SPEC.md" ]] || exit 0

CWD=$(pwd)
REL="${FILE_PATH#$CWD/}"

# Extract out_of_scope patterns from SPEC.md
PATTERNS=$(awk '
  /^out_of_scope:/ { in_block=1; next }
  /^[a-z_]+:/      { if (in_block) exit }
  in_block && /^[[:space:]]*-[[:space:]]*"/ {
    sub(/^[[:space:]]*-[[:space:]]*"/, "")
    sub(/".*/, "")
    print
  }
' SPEC.md)

[[ -z "$PATTERNS" ]] && exit 0

while IFS= read -r pat; do
  [[ -z "$pat" ]] && continue
  # shellcheck disable=SC2254
  case "$REL" in
    $pat)
      echo "⚠️  SCOPE WARN: '$REL' matches out_of_scope pattern '$pat' from SPEC.md." >&2
      echo "   This edit will be logged as 'side_quest' in .audit/." >&2
      echo "   If intentional + persistent: update SPEC.md scope." >&2
      echo "   If a one-off: add a one-line note to TASKS.md ## Discovered." >&2
      exit 0
      ;;
  esac
done <<< "$PATTERNS"

exit 0
