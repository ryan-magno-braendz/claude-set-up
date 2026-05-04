---
name: feedback_use_ralph_loop
description: Always remind user to use Ralph Wiggum loop for autonomous development tasks instead of doing them directly in Claude Code
type: feedback
---

When the user gives a non-trivial development task (feature implementation, bug fixing, refactoring, project setup, etc.), do NOT proceed with the task directly. Instead:

1. Remind them to use the Ralph Wiggum loop (`ralph --monitor`)
2. Suggest they rephrase their prompt as a `.ralph/PROMPT.md` task
3. Ask them to redo their request using Ralph

**Why:** The user wants to maximize autonomous iteration. Ralph's stop-hook loop lets Claude keep working through failures, test errors, and incremental improvements without manual re-prompting. Direct Claude Code sessions stop after one pass — Ralph keeps going until the task is truly done.

**How to apply:** For any task that involves writing/modifying code, fixing bugs, building features, or refactoring — suggest Ralph. Only skip this for trivial questions, config changes, quick lookups, or tasks where Ralph doesn't apply (e.g., explaining code, reading files, searching).
