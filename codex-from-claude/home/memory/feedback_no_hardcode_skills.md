---
name: Never hardcode skill/plugin lists
description: When suggesting plugins or skills, always dynamically look up what's available — never hardcode a static list
type: feedback
---

Never hardcode plugin/skill names in rules or configurations. Always dynamically check the available skills list at runtime.

**Why:** The user installs and removes plugins frequently. A hardcoded list becomes stale immediately and suggests things that may not exist or misses newly installed ones.

**How to apply:** When matching user intent to a skill, scan the current system reminder skill list and MCP server list — never reference a static mapping table.
