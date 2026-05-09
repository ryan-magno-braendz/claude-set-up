#!/bin/bash
# Hook: Notification — Mac notification + Apple Watch via ntfy

# Mac notification
osascript -e 'display notification "Claude needs your input" with title "Claude Code" sound name "Glass"' 2>/dev/null

# Apple Watch via ntfy
curl -s -H "Title: Claude Code" -H "Priority: high" -d "Claude needs your input" ntfy.sh/gabrielmagno-claude > /dev/null 2>&1 &

exit 0
