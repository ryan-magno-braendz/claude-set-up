#!/usr/bin/env bash
# Hook: play a completion ding when Codex finishes.

if command -v afplay >/dev/null 2>&1 && [ -f /System/Library/Sounds/Glass.aiff ]; then
  afplay /System/Library/Sounds/Glass.aiff >/dev/null 2>&1 &
elif command -v powershell.exe >/dev/null 2>&1; then
  powershell.exe -NoProfile -Command "[Console]::Beep(880, 180)" >/dev/null 2>&1 &
elif command -v pwsh >/dev/null 2>&1; then
  pwsh -NoProfile -Command "[Console]::Beep(880, 180)" >/dev/null 2>&1 &
else
  printf '\a'
fi

if command -v curl >/dev/null 2>&1; then
  curl -s -H "Title: Codex" -H "Priority: high" -d "Response ready" ntfy.sh/gabrielmagno-claude >/dev/null 2>&1 &
fi

exit 0
