#!/bin/bash
# Hook: Ding sound + Apple Watch notification when Claude finishes
# Uses ntfy.sh to push to iPhone → Apple Watch

# Mac sound
afplay /System/Library/Sounds/Glass.aiff &

# Apple Watch via ntfy
curl -s -H "Title: Claude Code" -H "Priority: high" -d "Response ready" ntfy.sh/gabrielmagno-claude > /dev/null 2>&1 &

exit 0
