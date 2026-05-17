#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SRC="${CODEX_SOURCE_HOME:-$HOME/.codex}"
DST="$PROJECT_DIR/home"

if [ ! -d "$SRC" ]; then
  echo "ERROR: source Codex home not found: $SRC" >&2
  exit 1
fi

if [ ! -f "$SRC/config.toml" ]; then
  echo "ERROR: source config.toml not found: $SRC/config.toml" >&2
  exit 1
fi

TMP="$(mktemp -d)"
cleanup() {
  rm -rf "$TMP"
}
trap cleanup EXIT

mkdir -p "$TMP/home"

copy_path() {
  local rel="$1"
  if [ -e "$SRC/$rel" ]; then
    mkdir -p "$TMP/home/$(dirname "$rel")"
    rsync -a --exclude='.git/' "$SRC/$rel" "$TMP/home/$rel"
  fi
}

copy_path "AGENTS.md"
copy_path "CLAUDE.md"
copy_path "config.toml"
copy_path "hooks.json"
copy_path "version.json"
copy_path "gsd-file-manifest.json"
copy_path "agents/"
copy_path "hooks/"
copy_path "skills/"
copy_path "rules/"
copy_path "memory/"
copy_path "reference/"
copy_path "get-shit-done/"
copy_path "plugins/cache/"
copy_path "vendor_imports/"
copy_path ".tmp/bundled-marketplaces/openai-bundled/"

rm -f "$TMP/home/hooks/notify.sh" "$TMP/home/hooks/ding.sh"

node "$SCRIPT_DIR/sanitize-codex-home.mjs" "$TMP/home"
node "$SCRIPT_DIR/verify-codex-home.mjs" "$TMP/home"

rm -rf "$DST"
mkdir -p "$DST"
rsync -a "$TMP/home/" "$DST/"

echo "Snapshot refreshed from $SRC into $DST"
find "$DST" -maxdepth 1 -mindepth 1 -print | sort
