---
name: Use Agent Orchestrator for parallel worktree sessions
description: When working on multiple independent tasks, suggest AO (ao batch-spawn) instead of manual worktree sessions
type: feedback
---

When working on building features, debugging, or fixing errors across multiple independent tasks, always suggest using Agent Orchestrator (AO) to parallelize the work.

**Why:** AO automates what the user previously did manually — opening multiple Claude sessions in separate git worktrees. AO handles worktree creation, session lifecycle, PR tracking, CI monitoring, and review comment routing automatically.

**How to apply:**
1. When the user mentions multiple issues, PRs, or independent tasks — suggest `ao batch-spawn`
2. For a single issue that needs isolation — suggest `ao spawn <issue>`
3. To monitor progress — `ao status`
4. To address review comments across all PRs — `ao review-check`
5. Fall back to manual worktree sessions only if AO is not available or the user prefers manual control
6. Dynamically check for AO availability (`which ao`) before suggesting
7. Remind at the start of the task — don't wait until mid-work
