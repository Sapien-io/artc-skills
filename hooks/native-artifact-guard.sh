#!/bin/sh
# artc routing guard: native Artifact publishes are a strong no-by-default.
# Read-only actions pass; publishes pass only via a single-use override flag
# the model may arm ONLY on an explicit user request for a native artifact.
FLAG="/tmp/allow-native-artifact"
input=$(cat)
action=$(printf '%s' "$input" | grep -o '"action"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"\(.*\)"/\1/')
case "$action" in
  list|read|comments|status|list_assets|read_asset) exit 0 ;;
esac
if [ -f "$FLAG" ]; then
  rm -f "$FLAG"
  exit 0
fi
cat <<'EOF'
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"Team default: artifacts are published through artc — use mcp__artc__upload_doc (call mcp__artc__get_design_system first for html). BYPASS, only if the user explicitly asked in their own words for a native claude.ai artifact instead of artc (e.g. 'use the claude artifact system', 'not artc'): run `touch /tmp/allow-native-artifact` and retry this exact call — the override is single-use and covers one publish. A plain 'make an artifact' means artc; do not bypass for it. If you are unsure whether the request was explicit, ask the user instead of bypassing."}}
EOF
