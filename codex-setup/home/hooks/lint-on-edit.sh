#!/bin/bash
# Hook: PostToolUse (Edit|Write) — Auto-lint/format after file edits
# Detects the project's formatter and runs it on the edited file.

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Skip if no file path
if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

# Get file extension
EXT="${FILE_PATH##*.}"
DIR=$(dirname "$FILE_PATH")

# Find project root (walk up to find package.json, pyproject.toml, etc.)
find_project_root() {
  local dir="$1"
  while [ "$dir" != "/" ]; do
    if [ -f "$dir/package.json" ] || [ -f "$dir/pyproject.toml" ] || [ -f "$dir/go.mod" ] || [ -f "$dir/Cargo.toml" ]; then
      echo "$dir"
      return
    fi
    dir=$(dirname "$dir")
  done
  echo "$1"
}

PROJECT_ROOT=$(find_project_root "$DIR")

case "$EXT" in
  js|jsx|ts|tsx|css|scss|json|md|html|vue|svelte|yaml|yml)
    # Try Prettier first (most common for web projects)
    if [ -f "$PROJECT_ROOT/node_modules/.bin/prettier" ]; then
      "$PROJECT_ROOT/node_modules/.bin/prettier" --write "$FILE_PATH" 2>/dev/null
    elif command -v npx &>/dev/null && [ -f "$PROJECT_ROOT/package.json" ]; then
      # Check if prettier is a dependency before running npx
      if grep -q "prettier" "$PROJECT_ROOT/package.json" 2>/dev/null; then
        npx --no-install prettier --write "$FILE_PATH" 2>/dev/null
      fi
    fi

    # Also run ESLint fix if available (for js/ts files)
    case "$EXT" in
      js|jsx|ts|tsx|vue|svelte)
        if [ -f "$PROJECT_ROOT/node_modules/.bin/eslint" ]; then
          "$PROJECT_ROOT/node_modules/.bin/eslint" --fix "$FILE_PATH" 2>/dev/null
        fi
        ;;
    esac
    ;;

  py)
    # Python: try ruff (fast), then black
    if command -v ruff &>/dev/null; then
      ruff format "$FILE_PATH" 2>/dev/null
      ruff check --fix "$FILE_PATH" 2>/dev/null
    elif command -v black &>/dev/null; then
      black --quiet "$FILE_PATH" 2>/dev/null
    fi
    ;;

  go)
    if command -v gofmt &>/dev/null; then
      gofmt -w "$FILE_PATH" 2>/dev/null
    fi
    if command -v goimports &>/dev/null; then
      goimports -w "$FILE_PATH" 2>/dev/null
    fi
    ;;

  rs)
    if command -v rustfmt &>/dev/null; then
      rustfmt "$FILE_PATH" 2>/dev/null
    fi
    ;;

  kt|kts)
    if command -v ktlint &>/dev/null; then
      ktlint --format "$FILE_PATH" 2>/dev/null
    fi
    ;;

  java)
    if command -v google-java-format &>/dev/null; then
      google-java-format --replace "$FILE_PATH" 2>/dev/null
    fi
    ;;

  swift)
    if command -v swiftformat &>/dev/null; then
      swiftformat "$FILE_PATH" 2>/dev/null
    fi
    ;;
esac

# Always exit 0 — formatting failure should not block work
exit 0
