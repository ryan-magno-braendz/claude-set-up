#!/usr/bin/env bash
# setup-codex.sh
# Idempotent installer for the Codex CLI configuration in ../home/ into ~/.codex/.
# Backs up any existing ~/.codex/ to ~/.codex.bak.<timestamp> before writing.
# Supports --dry-run.

set -euo pipefail

DRY_RUN=0
for arg in "$@"; do
  case "$arg" in
    --dry-run|-n)
      DRY_RUN=1
      ;;
    -h|--help)
      cat <<EOF
Usage: $(basename "$0") [--dry-run]

Installs the Codex configuration from ../home/ to ~/.codex/.
With --dry-run, prints the file list and target tree without writing.
EOF
      exit 0
      ;;
    *)
      echo "Unknown argument: $arg" >&2
      exit 2
      ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$SCRIPT_DIR/../home"
DST="$HOME/.codex"

if [ ! -d "$SRC" ]; then
  echo "ERROR: source directory not found: $SRC" >&2
  exit 1
fi

SRC_FILE_COUNT=$(find "$SRC" -type f | wc -l | tr -d ' ')
echo "Source: $SRC ($SRC_FILE_COUNT files)"
echo "Target: $DST"
echo

if [ "$DRY_RUN" -eq 1 ]; then
  echo "=== DRY RUN ==="
  echo
  echo "Files that would be copied:"
  ( cd "$SRC" && find . -type f | sed 's|^\./|  |' ) | sort
  echo
  echo "Resulting tree at $DST:"
  ( cd "$SRC" && find . -type d | sed "s|^\.|$DST|; s|^|  |" ) | sort
  echo
  echo "No changes made."
  exit 0
fi

# Backup existing
if [ -d "$DST" ]; then
  TS=$(date +%Y%m%d-%H%M%S)
  BACKUP="$DST.bak.$TS"
  echo "Backing up existing $DST to $BACKUP"
  mv "$DST" "$BACKUP"
fi

mkdir -p "$DST"

# Copy contents (not the home/ directory itself)
( cd "$SRC" && tar c . ) | ( cd "$DST" && tar x )

CODEX_HOME_FOR_CONFIG="$DST"
find "$DST" -type f \( -name '*.toml' -o -name '*.json' -o -name '*.md' -o -name '*.sh' -o -name '*.js' -o -name '*.mjs' \) -print0 |
  xargs -0 perl -0pi -e "s#__CODEX_HOME__#${CODEX_HOME_FOR_CONFIG}#g"

# Make hooks executable
if [ -d "$DST/hooks" ]; then
  find "$DST/hooks" -type f \( -name '*.sh' -o -name '*.js' \) -exec chmod +x {} +
fi

DST_FILE_COUNT=$(find "$DST" -type f | wc -l | tr -d ' ')
echo
echo "Copied $DST_FILE_COUNT files."
if [ "$DST_FILE_COUNT" -ne "$SRC_FILE_COUNT" ]; then
  echo "WARNING: file count mismatch (source=$SRC_FILE_COUNT, target=$DST_FILE_COUNT)" >&2
  echo "This can be normal if symlinks were resolved. Inspect $DST manually." >&2
else
  echo "File counts match."
fi

cat <<EOF

Install complete.

Next steps:
  1. Set environment variables: TAVILY_API_KEY, N8N_HOSTINGER_API_KEY, N8N_CITYFLEET_API_KEY.
     (Add to your shell rc, or use a .env loader.)
  2. Run: codex --version
  3. Verify skills: codex /skills
  4. Verify hooks: edit a file under a Codex session, watch for non-notification hook output.
     Notification hooks are intentionally excluded from this mirror.

Troubleshooting and full guide: BOOTSTRAP.md (sibling of this script).
EOF
