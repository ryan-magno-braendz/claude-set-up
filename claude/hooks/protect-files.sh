#!/bin/bash
# Hook: PreToolUse (Edit|Write) — Block edits to sensitive files

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

PROTECTED=(
  ".env"
  ".env.local"
  ".env.production"
  ".env.staging"
  "package-lock.json"
  "yarn.lock"
  "pnpm-lock.yaml"
  "bun.lockb"
  "Cargo.lock"
  "poetry.lock"
  "go.sum"
  "Gemfile.lock"
  "composer.lock"
  ".git/"
  "credentials"
  "secrets"
  ".pem"
  ".key"
)

BASENAME=$(basename "$FILE_PATH")

for p in "${PROTECTED[@]}"; do
  if [[ "$FILE_PATH" == *"$p"* ]] || [[ "$BASENAME" == "$p" ]]; then
    echo "Blocked: '$FILE_PATH' matches protected pattern '$p'. Edit manually if needed." >&2
    exit 2
  fi
done

exit 0
