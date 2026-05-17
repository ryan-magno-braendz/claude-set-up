#!/bin/bash
# Hook: PostToolUse (Bash) — Log all bash commands for audit trail

INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
CWD=$(echo "$INPUT" | jq -r '.cwd // "."')
SESSION=$(echo "$INPUT" | jq -r '.session_id // "unknown"')

if [ -z "$CMD" ]; then
  exit 0
fi

LOG_DIR="$HOME/.codex/logs"
mkdir -p "$LOG_DIR"

# Append as JSONL
echo "$INPUT" | jq -c "{
  ts: (now | todate),
  session: .session_id,
  cwd: .cwd,
  cmd: .tool_input.command
}" >> "$LOG_DIR/command-log.jsonl" 2>/dev/null

exit 0
