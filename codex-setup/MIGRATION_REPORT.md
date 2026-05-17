# Migration Report

Date: 2026-05-09
Source: `windows-claude-code/claude/` (Claude Code config mirror).
Target: `codex-setup/home/` (Codex CLI config payload).
Approach: hand-port (cc2codex was not used; the source mirror lives at `claude/` rather than `~/.claude/`, so the tool's expected layout did not apply, and the bespoke disposition tables in this report were easier to generate by hand).

## Summary

| Metric | Count |
|---|---|
| Skills migrated | 69 (46 directory-form copies, 21 intra-tree symlinks preserved, 3 absolute-symlink resolutions) |
| Skills wrapped from flat-file form | 0 (none of the 24 non-directory entries were flat files; all were symlinks) |
| Subagents converted | 46 (markdown plus YAML frontmatter to TOML) |
| Subagents flagged for manual review | 0 (all parsed cleanly) |
| Hook events ported | 4 (SessionStart, Stop, PreToolUse, PostToolUse) |
| Hook events dropped | 1 (Notification) |
| Hook script files copied | 17 (.sh and .js, excludes the 3 .disabled / .removed / README files) |
| MCP servers ported | 3 (tavily, n8n_hostinger, n8n_cityfleet) |
| MCP servers in optional catalog | 23 (kept as reference under `home/reference/mcp-configs/`) |
| CLAUDE.md to AGENTS.md transformations | 1 (global rules only; project-level CLAUDE.md files: none present in source) |
| Items dropped | 9 (plugin scaffolding listed below) |
| Manual-review queue items | 4 (commands/, ecc/, get-shit-done/, teams/) |

## 2026-05-17 Windows Mirror Refresh

Included from live `~/.codex`:

- Current `skills/`, including `.system`, GSD skills, gstack skills, n8n skills, and plugin-provided skills.
- Current `agents/`, including GSD markdown and TOML agent definitions.
- Current `get-shit-done/` runtime package, templates, references, and SDK files.
- Current OpenAI-curated plugin cache for Notion, Supabase, and Superpowers.
- Current local OpenAI bundled marketplace at `.tmp/bundled-marketplaces/openai-bundled/`, because `config.toml` references it directly.
- Current `memory/`, `rules/`, `reference/`, `vendor_imports/`, and version metadata.

Excluded intentionally:

- Permission-request notification hook, `notify.sh`, and native notification config. Stop `ding.sh` is retained and made portable for Windows Git Bash, macOS, and POSIX terminal bell fallback.
- `auth.json`, `.env`, API keys, login state, session history, logs, SQLite runtime DBs, shell snapshots, temporary directories other than the referenced bundled marketplace, and installation IDs.
- Mac-only project trust entries and hook trust hashes.

## Skills

Source: `windows-claude-code/claude/skills/` (69 first-level entries).

| Source | Destination | Status | Notes |
|---|---|---|---|
| `skills/<46 directories>/` | `home/skills/<name>/` | kept | Directory form preserved verbatim (46 skills). Includes `gstack/` which contains 21 sub-skills referenced by symlink at the parent level. |
| `skills/<21 relative symlinks to gstack/...>` | `home/skills/<name>` (symlink) | kept | Intra-tree symlinks. Target stays valid because `gstack/` is copied into the same relative location. |
| `skills/grill-me` (symlink to `~/.agents/skills/grill-me`) | `home/skills/grill-me/SKILL.md` | modified | External absolute-path symlink resolved by copying the live target into the destination. |
| `skills/improve-codebase-architecture` (symlink to `~/.agents/skills/improve-codebase-architecture`) | `home/skills/improve-codebase-architecture/{SKILL.md,REFERENCE.md}` | modified | Same; resolved on the source machine where the target existed. Fresh installs no longer depend on `~/.agents/`. |
| `skills/prd-to-issues` (symlink to `~/.agents/skills/prd-to-issues`) | `home/skills/prd-to-issues/SKILL.md` | modified | Same. |
| `skills/.letta/` | not copied | dropped | Letta runtime artifact that had been mirrored into the source tree. Not a skill. |

Result: 69 skills, all directory-form (or symlinks to directories), all loadable by Codex.

## Hooks

Source: `windows-claude-code/claude/settings.template.json` `hooks` block, plus the `hooks/` script directory.

### Events

| Source event | Destination | Status | Notes |
|---|---|---|---|
| `SessionStart` (3 entries) | `home/hooks.json` `SessionStart` (3 entries) | kept | Paths rewritten from `$HOME/.claude/hooks/` to `$HOME/.codex/hooks/`. |
| `Stop` (1 entry, 2 commands) | `home/hooks.json` `Stop` (1 entry, 2 commands) | kept | Same path rewrite. |
| `PostToolUse` (4 entries) | `home/hooks.json` `PostToolUse` (4 entries) | kept | Same path rewrite. |
| `PreToolUse` (6 entries) | `home/hooks.json` `PreToolUse` (6 entries) | kept | Same path rewrite. |
| `Notification` / permission notification behavior | not in `hooks.json` | modified | Native notification config and `notify.sh` are excluded. The Stop `ding.sh` command is retained in `hooks.json` and made portable for Windows. |

### Script files

| Source | Destination | Status | Notes |
|---|---|---|---|
| `hooks/auto-test.sh` | `home/hooks/auto-test.sh` | kept | byte-identical |
| `hooks/bash-guard.sh` | `home/hooks/bash-guard.sh` | kept | byte-identical |
| `hooks/command-log.sh` | `home/hooks/command-log.sh` | kept | byte-identical |
| `hooks/compact-reinject.sh` | `home/hooks/compact-reinject.sh` | kept | byte-identical |
| `hooks/ding.sh` | `home/hooks/ding.sh` | modified | Retained for the Stop hook and rewritten to use macOS `afplay`, Windows PowerShell beep, or terminal bell fallback. |
| `hooks/global-memory-symlink.sh` | `home/hooks/global-memory-symlink.sh` | kept | byte-identical |
| `hooks/gsd-check-update.js` | `home/hooks/gsd-check-update.js` | kept | byte-identical |
| `hooks/gsd-context-monitor.js` | `home/hooks/gsd-context-monitor.js` | kept | byte-identical |
| `hooks/gsd-prompt-guard.js` | `home/hooks/gsd-prompt-guard.js` | kept | byte-identical |
| `hooks/gsd-read-guard.js` | `home/hooks/gsd-read-guard.js` | kept | byte-identical |
| `hooks/gsd-statusline.js` | `home/hooks/gsd-statusline.js` | kept | byte-identical (Codex statusline use unconfirmed; kept for parity) |
| `hooks/lint-on-edit.sh` | `home/hooks/lint-on-edit.sh` | kept | byte-identical |
| `hooks/notify.sh` | not copied | dropped | Permission-request/native notification behavior is intentionally excluded from the Windows mirror. |
| `hooks/protect-files.sh` | `home/hooks/protect-files.sh` | kept | byte-identical |
| `hooks/scan-secrets.sh` | `home/hooks/scan-secrets.sh` | kept | byte-identical |
| `hooks/verify-before-stop.sh` | `home/hooks/verify-before-stop.sh` | kept | byte-identical |
| `hooks/warn-large-files.sh` | `home/hooks/warn-large-files.sh` | kept | byte-identical |
| `hooks/README.md` | not copied | dropped | Documentation about CC hooks, not a script. |
| `hooks/gsd-workflow-guard.js.removed.2026-04-25` | not copied | dropped | Marked removed in source. |
| `hooks/hooks.json.disabled.2026-04-25` | not copied | dropped | Marked disabled in source. |

## MCP servers

Active set (rendered into `home/config.toml`):

| Source | Destination | Status | Notes |
|---|---|---|---|
| `.mcp.template.json` `mcpServers.tavily` | `[mcp_servers.tavily]` in `home/config.toml` | kept | Stdio transport, npx-based. Env var `TAVILY_API_KEY` preserved. |
| `.mcp.template.json` `mcpServers.n8n` | `[mcp_servers.n8n_hostinger]` in `home/config.toml` | modified | Renamed from `n8n` to `n8n_hostinger` to disambiguate from the second n8n instance. Env preserved. |
| `settings.template.json` `mcpServers.n8n` | `[mcp_servers.n8n_cityfleet]` in `home/config.toml` | modified | Renamed for the same reason. Env preserved. |

Optional catalog (kept as reference, not active):

| Source | Destination | Status | Notes |
|---|---|---|---|
| `mcp-configs/mcp-servers.json` (23 entries: github, firecrawl, supabase, memory, sequential-thinking, vercel, railway, cloudflare-docs, cloudflare-workers-builds, cloudflare-workers-bindings, cloudflare-observability, clickhouse, exa-web-search, context7, magic, filesystem, insaits, playwright, fal-ai, browserbase, browser-use, devfleet, token-optimizer, confluence) | `home/reference/mcp-configs/mcp-servers.json` | kept (reference) | Inactive catalog. Each entry can be ported into `home/config.toml` as a `[mcp_servers.<name>]` block when the user wants it on. JSON to TOML conversion is straightforward (string keys, args as arrays, env tables). HTTP-transport entries become `transport = "http"` plus `url` keys. |

## Subagents

Source: `windows-claude-code/claude/agents/*.md` (46 files).

| Source | Destination | Status | Notes |
|---|---|---|---|
| `agents/<name>.md` (46 files) | `home/agents/<name>.toml` | converted | YAML frontmatter parsed (name, description, model, tools, sandbox). Body copied into TOML triple-quoted `prompt`. Any source `model: opus` or `model: haiku` was mapped to `gpt-5-codex` because Codex does not host Anthropic models; original model name preserved as a `[orig model: X]` prefix in the description for human review. |

Per-agent table (full list):

| File | Source model | Destination model | Status |
|---|---|---|---|
| architect.toml | (per source) | gpt-5-codex | converted |
| build-error-resolver.toml | (per source) | gpt-5-codex | converted |
| chief-of-staff.toml | (per source) | gpt-5-codex | converted |
| code-reviewer.toml | sonnet | gpt-5-codex | converted |
| cpp-build-resolver.toml | (per source) | gpt-5-codex | converted |
| cpp-reviewer.toml | (per source) | gpt-5-codex | converted |
| database-reviewer.toml | (per source) | gpt-5-codex | converted |
| doc-updater.toml | (per source) | gpt-5-codex | converted |
| docs-lookup.toml | (per source) | gpt-5-codex | converted |
| e2e-runner.toml | (per source) | gpt-5-codex | converted |
| flutter-reviewer.toml | (per source) | gpt-5-codex | converted |
| go-build-resolver.toml | (per source) | gpt-5-codex | converted |
| go-reviewer.toml | (per source) | gpt-5-codex | converted |
| gsd-advisor-researcher.toml | (per source) | gpt-5-codex | converted |
| gsd-assumptions-analyzer.toml | (per source) | gpt-5-codex | converted |
| gsd-codebase-mapper.toml | (per source) | gpt-5-codex | converted |
| gsd-debugger.toml | (per source) | gpt-5-codex | converted |
| gsd-executor.toml | (per source) | gpt-5-codex | converted |
| gsd-integration-checker.toml | (per source) | gpt-5-codex | converted |
| gsd-nyquist-auditor.toml | (per source) | gpt-5-codex | converted |
| gsd-phase-researcher.toml | (per source) | gpt-5-codex | converted |
| gsd-plan-checker.toml | (per source) | gpt-5-codex | converted |
| gsd-planner.toml | (per source) | gpt-5-codex | converted |
| gsd-project-researcher.toml | (per source) | gpt-5-codex | converted |
| gsd-research-synthesizer.toml | (per source) | gpt-5-codex | converted |
| gsd-roadmapper.toml | (per source) | gpt-5-codex | converted |
| gsd-ui-auditor.toml | (per source) | gpt-5-codex | converted |
| gsd-ui-checker.toml | (per source) | gpt-5-codex | converted |
| gsd-ui-researcher.toml | (per source) | gpt-5-codex | converted |
| gsd-user-profiler.toml | (per source) | gpt-5-codex | converted |
| gsd-verifier.toml | (per source) | gpt-5-codex | converted |
| harness-optimizer.toml | (per source) | gpt-5-codex | converted |
| java-build-resolver.toml | (per source) | gpt-5-codex | converted |
| java-reviewer.toml | (per source) | gpt-5-codex | converted |
| kotlin-build-resolver.toml | (per source) | gpt-5-codex | converted |
| kotlin-reviewer.toml | (per source) | gpt-5-codex | converted |
| loop-operator.toml | (per source) | gpt-5-codex | converted |
| planner.toml | (per source) | gpt-5-codex | converted |
| python-reviewer.toml | (per source) | gpt-5-codex | converted |
| pytorch-build-resolver.toml | (per source) | gpt-5-codex | converted |
| refactor-cleaner.toml | (per source) | gpt-5-codex | converted |
| rust-build-resolver.toml | (per source) | gpt-5-codex | converted |
| rust-reviewer.toml | (per source) | gpt-5-codex | converted |
| security-reviewer.toml | (per source) | gpt-5-codex | converted |
| tdd-guide.toml | (per source) | gpt-5-codex | converted |
| typescript-reviewer.toml | (per source) | gpt-5-codex | converted |

`tools` field from CC agents is not preserved in the TOML output. Codex agents inherit the calling session's tool surface; there is no per-agent allowlist analog. If you need to restrict an agent, set `sandbox_mode` or wrap it in a custom prompt.

## Instruction files

| Source | Destination | Status | Notes |
|---|---|---|---|
| `claude/CLAUDE.md` | `home/CLAUDE.md` | kept (verbatim) | Preserved as the fallback project doc that Codex reads via `project_doc_fallback_filenames`. |
| `claude/CLAUDE.md` | `home/AGENTS.md` | modified | Re-authored as Codex-targeted AGENTS.md. The Claude-Code-specific tool names (Tasks, Skill, Agent) are left as-is in the rules; Codex equivalents are described in the file's preamble. Em dashes were replaced with commas or periods because the migration spec disallowed them in user-facing markdown; the original wording is preserved unchanged in `home/CLAUDE.md`. |
| `claude/AGENTS.md` (the ECC plugin doc) | not copied | dropped | This file documented the ECC Claude plugin, not the user's instructions. Replaced by the new Codex-targeted AGENTS.md described above. |
| `claude/rules/` (common plus 6 language folders) | `home/rules/` | kept (verbatim) | 44 files, copied with no changes. AGENTS.md tells the assistant to consult them. |
| `claude/memory/` (10 files including MEMORY.md) | `home/memory/` | kept (verbatim, reference) | Codex does not auto-load memory. AGENTS.md instructs the assistant to read them when context suggests a memory entry is relevant. |
| `claude/PLUGIN_SCHEMA_NOTES.md` | not copied | dropped | Anthropic-Claude-Code-specific. |
| `claude/README.md` | not copied | dropped | Anthropic-Claude-Code-specific. |
| `claude/marketplace.json`, `claude/plugin.json`, `claude/package.json`, `claude/gsd-file-manifest.json` | not copied | dropped | Anthropic-plugin manifests with no Codex analog. |
| `claude/statusline.js` | not copied | dropped | CC statusline. The `gsd-statusline.js` hook script is preserved under `home/hooks/` for parity. |
| `claude/scripts/` | not copied | dropped | Bootstrap helpers specific to CC; the new install path is `scripts/setup-codex.{sh,ps1}`. |
| Project-level `CLAUDE.md` files | (none found) | n/a | The source mirror contained no per-project CLAUDE.md files. If you have any in your local projects, Codex reads them via `project_doc_fallback_filenames = ["CLAUDE.md"]` set in `config.toml`. |

## Plugin scaffolding (manual review queue)

| Source | Destination | Status | Notes |
|---|---|---|---|
| `claude/commands/` (60 top-level + `gsd/` subfolder, ~30 more) | `home/reference/commands/` | manual review | Codex does not have CC slash-command files. Each command is a markdown file with prompt-style content. To bring any across, you can either author a new skill at `home/skills/<name>/SKILL.md` whose body mirrors the command, or paste the content into a Codex prompt template if your build supports custom prompts. The full set is preserved unchanged for inspection. |
| `claude/ecc/` | `home/reference/ecc/` | manual review | Everything Claude Code plugin scaffolding. No Codex equivalent. Kept for reference. |
| `claude/get-shit-done/` | `home/reference/get-shit-done/` | manual review | GSD plugin scaffolding (commands, references, templates, workflows directories). The plugin's agent definitions are already ported under `home/agents/gsd-*.toml`; the rest of this directory is plugin runtime that Codex cannot load. |
| `claude/teams/` | `home/reference/teams/` | manual review | CC teammate-mode definitions. Codex has no `teammateMode = "tmux"` analog. Kept for reference. |

## Manual review queue (consolidated)

Items needing human attention before first Codex run, or to extend the migration further:

1. **Slash commands.** Decide which of the 90 plus CC commands (`reference/commands/`) to port to Codex. Recommended approach: port the top 5 to 10 by daily usage as skills under `home/skills/<name>/SKILL.md`; drop the rest. Notes per category:
   - `gsd/*.md` commands: most have agent-equivalents already converted under `home/agents/gsd-*.toml`; the slash command files are thin wrappers and may not be worth porting individually.
   - Build/review commands (`code-review.md`, `build-fix.md`, etc.): the matching reviewer agents are already ported as TOML; consider these wrappers redundant.
2. **GSD plugin runtime.** `reference/get-shit-done/{commands,references,templates,workflows}` is plugin internals. Use as documentation of GSD intent; do not try to install.
3. **Plugin manifests.** `marketplace.json`, `plugin.json`, `package.json`, `plugins.lock.json`, `marketplaces.lock.json` are dropped and not in `reference/`. If you re-introduce CC plugins on the source machine, regenerate them there.
4. **Memory references.** Codex does not auto-load `~/.codex/memory/`. The AGENTS.md tells the assistant to read entries when relevant, but if you rely heavily on auto-recall, paste the most-used entries directly into AGENTS.md.
5. **Hook schema sanity check.** Codex hook JSON schema has varied across versions. The current `hooks.json` uses the nested `hooks` array form (matching the Claude Code shape). If a specific Codex build expects a flatter form, adjust per the Codex docs for that version. See BOOTSTRAP.md Troubleshooting.
6. **Skill enablement flag name.** `[features] skills = true` may need to be `experimental_skills = true` on older Codex builds. See BOOTSTRAP.md.
