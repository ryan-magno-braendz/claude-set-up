# codex-setup

A self-contained Codex CLI configuration derived from the live Codex setup on this machine. Drop this folder onto a fresh machine, run one script, and Codex starts up with the same global instructions, skills, agents, hooks, plugins, and active MCP config as the source environment. Native notification config and the permission-request notification hook are excluded; the Stop `ding.sh` hook is included.

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
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\scripts\setup-codex.ps1 -DryRun
.\scripts\setup-codex.ps1
codex login
codex --version
```

macOS or Linux:
```bash
./scripts/setup-codex.sh
```

Both support `--dry-run` (or `-DryRun` on PowerShell) for a preview without writing.

After the script finishes, set `TAVILY_API_KEY` if you want Tavily MCP available immediately, then run `codex --version` to confirm.

Full guide, prerequisites, and troubleshooting: `BOOTSTRAP.md`.

## What is in `home/`

| Path | Source equivalent |
|---|---|
| `home/AGENTS.md` | Codex-targeted global instructions from the live setup. |
| `home/CLAUDE.md` | Original Claude fallback project doc. |
| `home/config.toml` | Current Codex settings, MCP servers, plugins, GSD agent registrations, with machine paths templated as `__CODEX_HOME__`. |
| `home/hooks.json` | Current hooks. Native notification and permission-request notification hooks are intentionally excluded; Stop `ding.sh` is retained. |
| `home/hooks/` | Hook scripts used by the live setup, including portable `ding.sh`. |
| `home/skills/` | Current live skill directories, including GSD, gstack, n8n, and plugin-provided skills. |
| `home/agents/` | Current live subagent TOML and markdown definitions. |
| `home/rules/` | Layered coding rules. |
| `home/memory/` | Reference memory files. |
| `home/reference/` | Read-only reference archive. |
| `home/get-shit-done/` | Current local GSD runtime package and templates needed by GSD skills. |
| `home/plugins/cache/` | Cached OpenAI-curated Notion, Supabase, and Superpowers plugin skills. |
| `home/vendor_imports/` | Current vendor import metadata. |
| `home/.tmp/bundled-marketplaces/openai-bundled/` | Local bundled marketplace referenced by `config.toml`; other `.tmp` runtime content is excluded. |

## What was not migrated

Short list:
- Permission-request notification hook, `notify.sh`, and native notification config. Stop `ding.sh` is included.
- API keys, login state, session history, logs, caches, SQLite runtime DBs, shell snapshots, and installation IDs.
- Mac-only project trust entries and hook trust hashes.

Full per-artifact disposition: `MIGRATION_REPORT.md`.
