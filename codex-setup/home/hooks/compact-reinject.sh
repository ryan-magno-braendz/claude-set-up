#!/bin/bash
# Hook: SessionStart/PostCompact - Re-inject project context after compaction
# Reads project-status.md and architecture.md so Codex doesn't lose context.

INPUT=$(cat)
CWD=$(echo "$INPUT" | jq -r '.cwd // "."')
HOOK_EVENT=$(echo "$INPUT" | jq -r '.hook_event_name // ""')

# PreCompact is registered so the hook is active, but this script only needs to
# emit context after compaction or on session start/resume.
if [ "$HOOK_EVENT" = "PreCompact" ]; then
  exit 0
fi

# Try to find docs directory
DOCS_DIR=""
if [ -d "$CWD/docs" ]; then
  DOCS_DIR="$CWD/docs"
elif [ -d "$CWD/documentation" ]; then
  DOCS_DIR="$CWD/documentation"
fi

if [ -z "$DOCS_DIR" ]; then
  exit 0
fi

echo "=== PROJECT CONTEXT (re-injected after compaction) ==="
echo ""

# Project status — where we left off
if [ -f "$DOCS_DIR/project-status.md" ]; then
  echo "--- PROJECT STATUS ---"
  cat "$DOCS_DIR/project-status.md"
  echo ""
fi

# Architecture — system design context
if [ -f "$DOCS_DIR/architecture.md" ]; then
  echo "--- ARCHITECTURE ---"
  cat "$DOCS_DIR/architecture.md"
  echo ""
fi

# Recent troubleshooting — avoid repeating failed approaches
if [ -f "$DOCS_DIR/troubleshooting.md" ]; then
  echo "--- RECENT TROUBLESHOOTING (last 50 lines) ---"
  tail -50 "$DOCS_DIR/troubleshooting.md"
  echo ""
fi

exit 0
