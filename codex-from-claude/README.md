# codex-from-claude

A self-contained Codex CLI configuration derived from Ryan's working Claude Code setup. Drop this folder onto a fresh machine, run one script, and Codex starts up with the same global instructions, skills, agents, hooks, and MCP servers as the source CC environment.

## Files

| Path | Purpose |
|---|---|
| `BOOTSTRAP.md` | Step-by-step install guide. The contract for this folder. Read this first on a new machine. |
| `INSTALL_PROMPT.md` | Paste-into-Codex prompt for hands-off install. Codex reads the local repo and drives the setup end to end. |
| `MIGRATION_REPORT.md` | Per-artifact disposition (kept, modified, dropped) with reasons. |
| `home/` | Mirror of the target `~/.codex/`. The setup script copies its contents into place. |
| `scripts/setup-codex.sh` | POSIX installer. Backs up existing `~/.codex/`, copies `home/` into place, supports `--dry-run`. |
| `scripts/setup-codex.ps1` | Windows PowerShell installer with the same behavior. |

## Install

From this directory:

Windows:
```powershell
.\scripts\setup-codex.ps1
```

macOS or Linux:
```bash
./scripts/setup-codex.sh
```

Both support `--dry-run` (or `-DryRun` on PowerShell) for a preview without writing.

After the script finishes, set environment variables (`TAVILY_API_KEY`, `N8N_HOSTINGER_API_KEY`, `N8N_CITYFLEET_API_KEY`) and run `codex --version` to confirm.

Full guide, prerequisites, and troubleshooting: `BOOTSTRAP.md`.

## What is in `home/`

| Path | Source equivalent |
|---|---|
| `home/AGENTS.md` | Codex-targeted rewrite of the global `CLAUDE.md`. |
| `home/CLAUDE.md` | Original `CLAUDE.md` kept verbatim as the Codex fallback project doc. |
| `home/config.toml` | Feature flags, MCP server definitions, project-doc fallback to `CLAUDE.md`. |
| `home/hooks.json` | Codex hooks config, filtered to supported events (SessionStart, Stop, PreToolUse, PostToolUse). The Notification event was dropped. |
| `home/hooks/` | 17 hook scripts copied verbatim. |
| `home/skills/` | 69 skills, all directory-form. |
| `home/agents/` | 46 subagent TOMLs converted from CC markdown. |
| `home/rules/` | Layered coding rules (common plus 6 language folders). |
| `home/memory/` | Reference memory files (Codex does not auto-load these; AGENTS.md says when to read them). |
| `home/reference/` | Read-only archive of CC items with no Codex analog (slash commands, plugin scaffolding). Inspect manually; do not import. |

## What was not migrated

Short list:
- The CC Notification hook event (Codex has no equivalent).
- 90+ CC slash commands (preserved under `home/reference/commands/` for manual review).
- Plugin scaffolding (`ecc/`, `get-shit-done/`, `teams/`, plugin/marketplace manifests).
- Anthropic model identifiers in agent files (mapped to `gpt-5-codex`; original model name kept in description for review).

Full per-artifact disposition: `MIGRATION_REPORT.md`.
