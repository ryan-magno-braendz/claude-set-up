#!/bin/bash
# Ensures the project memory dir is a symlink to the global ~/.claude/memory/
# Runs on SessionStart to handle new projects automatically.

GLOBAL_MEMORY="$HOME/.claude/memory"
PROJECT_DIR="$HOME/.claude/projects"

# Ensure global memory directory exists
mkdir -p "$GLOBAL_MEMORY"

# Find any project memory dirs that are real directories (not symlinks) and replace them
find "$PROJECT_DIR" -maxdepth 2 -type d -name "memory" 2>/dev/null | while read dir; do
  # If there are files in the project memory dir, merge them first
  if [ "$(ls -A "$dir" 2>/dev/null)" ]; then
    cp -n "$dir"/* "$GLOBAL_MEMORY/" 2>/dev/null || true
  fi
  rm -rf "$dir"
  ln -s "$GLOBAL_MEMORY" "$dir"
done
