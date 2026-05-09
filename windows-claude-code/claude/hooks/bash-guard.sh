#!/bin/bash
# Hook: PreToolUse (Bash) — Block destructive commands

INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if [ -z "$CMD" ]; then
  exit 0
fi

# Exact patterns to block
BLOCKED=(
  "rm -rf /"
  "rm -rf ~"
  "rm -rf \$HOME"
  "DROP TABLE"
  "DROP DATABASE"
  "TRUNCATE TABLE"
  "git push --force"
  "git push -f"
  "git reset --hard"
  "git clean -fd"
  "git checkout -- ."
  "--no-verify"
  "--no-gpg-sign"
  "sudo rm"
  "> /dev/sda"
  "mkfs"
  ":(){:|:&};:"
  "migrate reset"
  "db:reset"
  "db:drop"
  "dropdb"
  "chmod 777"
  "chmod -R 777"
)

for b in "${BLOCKED[@]}"; do
  if echo "$CMD" | grep -qi "$b"; then
    echo "Blocked: Command contains '$b'. This is a destructive operation. Run manually if intentional." >&2
    exit 2
  fi
done

exit 0
