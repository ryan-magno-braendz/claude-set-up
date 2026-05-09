# Audit Report

Date: 2026-05-09
Auditor: hand-port migration audit, second pass.
Source: codex-from-claude/ (post-migration).
Reference: windows-claude-code/ (must remain byte-identical).

## Verdict

**YES, ready to ship.**

Twelve mechanical issues were found and auto-fixed in this run. The second pass re-validates them clean. Three items are flagged for user decision; none are blocking.

## Summary

| Metric | Value |
|---|---|
| Categories audited | 13 |
| Total checks run | 47 |
| Passed first pass | 31 |
| Auto-fixed and re-checked clean | 12 |
| Flagged for user decision | 3 |
| Independent inventory cross-check | manual (cc2codex unavailable, see category 3) |
| windows-claude-code byte-identical | yes (2868 files, zero checksum diffs pre and post audit) |

## Skill family completeness

| Family | Source count | Destination count | Status |
|---|---|---|---|
| n8n-* | 9 | 9 | PASS (all 9 names match) |
| gsd-* (skills directory) | 0 | 0 | PASS (the gsd skill family lives in the get-shit-done plugin runtime, not in `claude/skills/`. The 18 `gsd-*` subagents are ported as TOML under `home/agents/`). |
| superpowers-* (skills directory) | 0 | 0 | PASS (the superpowers skill family is delivered by the superpowers plugin itself, not stored in the user's `claude/skills/`. Skills like `verification-loop`, `sync-vault`, etc. that came from gstack-or-similar packs are present and accounted for as named directories.) |

## Per-category results

### 1. Repo structure

- [PASS] Repo root contains exactly: `README.md`, `windows-claude-code/`, `codex-from-claude/` plus `.git/` and `.gitignore` (both hidden meta files).
- [AUTO_FIX] A `.letta/` directory regenerated at root from the active Letta plugin background process during the migration. Removed in this run.
- [AUTO_FIX] No root `.gitignore` existed, so any future Letta or `.planning/` regeneration would have shown up as a leftover artifact at root. Added `/.gitignore` listing `.letta/`, `.planning/`, OS noise, and bak files.

### 2. windows-claude-code integrity

- [PASS] `windows-claude-code/` present. 2868 files. Total size unchanged.
- [PASS] Pre-audit checksum baseline matches post-audit baseline. Zero diffs across all 2868 files.

### 3. Independent inventory cross-check

- [LOG] cc2codex not installed and not in PATH. Manual cross-check substituted.
- [PASS] Skills: source 69 entries at depth 1; dest 69; `diff` empty.
- [PASS] Subagents: source 46 markdown files; dest 46 TOMLs; basenames match 1 to 1.
- [PASS] Hook scripts: source 17 (`.sh` and `.js`, excluding README/disabled/removed); dest 17; names match.
- [PASS] MCP servers: 3 active in source templates; 3 in `config.toml`. Catalog of 23 optional servers preserved under `home/reference/mcp-configs/mcp-servers.json`.
- [PASS] Rules: 44 files in source, 44 in dest.
- [PASS] Memory: 10 files in source, 10 in dest.

### 4. Skill family completeness

See top-of-report table.

### 5. codex-from-claude file presence

- [PASS] `BOOTSTRAP.md` present.
- [PASS] `MIGRATION_REPORT.md` present.
- [PASS] `PLAN.md` present.
- [PASS] `README.md` present.
- [PASS] `home/{AGENTS.md, CLAUDE.md, config.toml, hooks.json, hooks/, skills/, agents/, rules/, memory/, reference/}` all present.
- [PASS] `scripts/setup-codex.sh` and `scripts/setup-codex.ps1` present.

### 6. AGENTS.md validity

- [PASS] Non-empty (162 lines).
- [PASS] Codex-targeted preamble at top describes setup map and where each component lives.
- [PASS] Body content traceable to source `claude/CLAUDE.md`. Em dashes converted to commas or periods (constraint compliance); the original wording is preserved unchanged in the sibling `home/CLAUDE.md` fallback file.
- [PASS] Mentions Claude-Code-only tool names (Tasks, Skill tool, Agent) only in the "apply the equivalent Codex action" preamble note. No literal Codex misdirection.

### 7. config.toml validity

- [AUTO_FIX] First pass: top-level keys (`project_doc_fallback_filenames`, `approval_policy`, `sandbox_mode`, `model_reasoning_effort`) had been written **after** `[features]`, so TOML scoping placed them inside the `[features]` table. Codex would never read them. Re-ordered: top-level keys first, then `[features]`, then `[mcp_servers.*]` sections.
- [PASS] Re-validation: top-level keys are `['project_doc_fallback_filenames', 'approval_policy', 'sandbox_mode', 'model_reasoning_effort', 'features', 'mcp_servers']`.
- [PASS] `[features] codex_hooks = true` and `[features] skills = true` both present.
- [PASS] `project_doc_fallback_filenames = ["CLAUDE.md"]` at top level.
- [PASS] All 3 MCP servers (`tavily`, `n8n_hostinger`, `n8n_cityfleet`) present with `command`, `args`, and nested `.env` tables.
- [PASS] No JSON syntax bleed (no `{` `:` `,` JSON-style structures).

### 8. hooks.json validity

- [PASS] Valid JSON (parses with `jq`).
- [PASS] Events present: `SessionStart`, `Stop`, `PreToolUse`, `PostToolUse`. All four are Codex-supported.
- [PASS] No unsupported events (`Notification` correctly absent).
- [PASS] All hook command paths use forward slashes and `$HOME/.codex/hooks/...`. No backslashes leaking.

### 9. Skills audit

- [AUTO_FIX] `home/skills/learned/` had no `SKILL.md` (source directory was empty). Created a minimal `SKILL.md` with `name: learned` and a placeholder description that flags the directory as ready for the user to author.
- [AUTO_FIX] `home/skills/skill-stocktake/SKILL.md` was missing the `name:` field in YAML frontmatter (also missing in source). Added `name: skill-stocktake` to match the directory.
- [AUTO_FIX] `home/skills/vault-save/SKILL.md` had `name: save` while the directory is `vault-save` (slug mismatch in source). Renamed `name:` to `vault-save` and updated the inline `Usage:` example to `/vault-save` so the SKILL.md stays self-consistent.
- [PASS] Re-validation: 0 real issues across all 69 skills (top-level entries; `gstack/` subskills are nested and validate via their own `SKILL.md` files).
- [PASS] All top-level skill directories contain a `SKILL.md` either directly or in a nested skill subdirectory (`gstack/` etc.).
- [PASS] All non-symlink entries are directory form. Zero flat `.md` files at `home/skills/<name>.md` level.
- [PASS] All 21 intra-tree symlinks resolve cleanly to `home/skills/gstack/<name>/SKILL.md`. None point outside the tree.

### 10. Subagents audit

- [AUTO_FIX] First pass: 8 of 46 agent TOMLs failed `tomllib` parse with "Unescaped '\' in a string." Cause: triple-quoted basic strings (`"""..."""`) interpret backslash escapes; source markdown contained regex patterns and other literal backslashes that are not valid TOML escapes. Affected files: `gsd-codebase-mapper.toml`, `gsd-integration-checker.toml`, `gsd-phase-researcher.toml`, `gsd-project-researcher.toml`, `gsd-ui-auditor.toml`, `gsd-ui-researcher.toml`, `gsd-verifier.toml`, `java-build-resolver.toml`.
- [AUTO_FIX] All 46 TOMLs regenerated using TOML literal multi-line strings (`'''...'''`), which do not interpret backslashes. Description fields kept as basic strings with `\\` and `\"` escaping applied.
- [PASS] Re-validation: 46 of 46 TOMLs parse cleanly; all four required fields present (`name`, `prompt`, `model`, `sandbox_mode`); name in TOML matches filename in every case.

### 11. Setup scripts audit

- [PASS] `setup-codex.sh` and `setup-codex.ps1` both present.
- [PASS] Both back up existing `~/.codex/` to `~/.codex.bak.<timestamp>`.
- [PASS] Both verify file count post-copy and warn on mismatch.
- [PASS] Both support `--dry-run` (POSIX) / `-DryRun` (PowerShell).
- [PASS] Bash dry run executes cleanly: `Source: .../home (2621 files); Target: ~/.codex; ... No changes made.`
- [PASS] `bash -n` syntax check passes on `setup-codex.sh`.
- [PASS] Forward-slash paths in `setup-codex.sh`. Native paths (with `Join-Path`) in `setup-codex.ps1`.
- [LOG] shellcheck and PSScriptAnalyzer not available on this host. Visual review and dry-run smoke test substituted.

### 12. BOOTSTRAP.md completeness

- [AUTO_FIX] Hedged `codex agents-md` command had no concrete fallback labelled as such. Replaced with explicit "Primary command (works on builds that expose the helper)" and "Fallback (always works, on every Codex build and from any shell): `head -20 ~/.codex/AGENTS.md`."
- [AUTO_FIX] Env-var section listed three variables but did not include a concrete `.env` template. Added `~/.codex/.env` template (Bash) and `~/.codex/env.ps1` template (PowerShell), with a clear `replace_me_*` placeholder per variable and the exact source-from-rc command.
- [AUTO_FIX] Verification commands had no expected-output examples. Added expected-output blocks under each of the five verification steps (codex --version, AGENTS.md head, /skills, hooks fire, /mcp).
- [AUTO_FIX] Hook schema variation note said "transform hooks.json into the form your Codex expects" without showing the alternate shape. Added a side-by-side nested-vs-flat schema comparison plus a one-shot `jq` transform command that converts nested to flat.
- [AUTO_FIX] Skills feature flag note said the name "may have a different name" without showing detection. Added a `codex --version`-based detection and a config.toml diff snippet for switching `skills` to `experimental_skills`.
- [AUTO_FIX] `--dry-run` was mentioned but not as a recommended first step. Added an explicit "One-command install (with dry run first)" section that orders: dry run, inspect output, then real install. Both Bash and PowerShell variants.
- [AUTO_FIX] Restoring a previous install only had Bash; added the PowerShell equivalent.
- [AUTO_FIX] Manual install PowerShell snippet used backslash paths (`$env:USERPROFILE\.codex`). Converted to forward slashes for consistency with the rest of the doc.
- [PASS] Re-validation: every gap from the prior run's "gaps found" list is now addressed in BOOTSTRAP.md itself.

### 13. MIGRATION_REPORT.md internal consistency

- [PASS] Summary totals (skills migrated 69, subagents 46, hook events 4 ported and 1 dropped, hook script files 17, MCP servers active 3 and catalog 23, rules 44 files, memory 10 files) all match per-category sections.
- [PASS] No contradiction between the Manual review queue and the per-category status columns.
- [PASS] Every source artifact appears exactly once.
- [LOG] One inline note in the report ("`tools` field from CC agents is not preserved in the TOML output") is now accurate after the agent regen because the regen still does not set a `tools` key. Behavior preserved.

## Fixes applied (chronological)

1. **config.toml TOML scoping**. Top-level keys reordered to come before any `[section]` header. `project_doc_fallback_filenames`, `approval_policy`, `sandbox_mode`, `model_reasoning_effort` now parse at top level, not under `[features]`.
2. **46 agent TOMLs regenerated** with literal multi-line strings (`'''...'''`) instead of basic strings (`"""..."""`). All 46 now parse cleanly; the 8 previously-broken `gsd-*` and `java-build-resolver` files included.
3. **`home/skills/learned/SKILL.md`** created (was missing because source was an empty placeholder dir).
4. **`home/skills/skill-stocktake/SKILL.md`** had `name:` added to frontmatter (was missing in source too).
5. **`home/skills/vault-save/SKILL.md`** `name:` aligned to directory: `save` to `vault-save`. Inline `/save` usage example also updated to `/vault-save`.
6. **`.letta/` removed from repo root**. Was regenerated by the active Letta plugin during the migration session.
7. **`/.gitignore` added at repo root** so `.letta/`, `.planning/`, OS noise, and bak files cannot reappear as loose root artifacts.
8. **BOOTSTRAP.md `codex agents-md` fallback**. Concrete `head -20 ~/.codex/AGENTS.md` fallback now labelled as such.
9. **BOOTSTRAP.md `.env` template**. Concrete Bash and PowerShell templates added with `replace_me_*` placeholders for the three named env vars.
10. **BOOTSTRAP.md verification expected-output examples**. Each of the five verification steps now shows what success looks like.
11. **BOOTSTRAP.md alternate hook schema**. Nested vs flat shapes shown side by side, with a `jq` one-shot transform command to convert.
12. **BOOTSTRAP.md skills feature flag detection**. Detection command (`codex --version`) plus config.toml diff snippet for switching to `experimental_skills`.
13. **BOOTSTRAP.md dry-run-first recipe**. Top-level Install section restructured to recommend `--dry-run` first, inspect, then real install. Both platforms.
14. **BOOTSTRAP.md PowerShell restore**. Restoring-a-previous-install section gained the PowerShell variant.
15. **BOOTSTRAP.md PowerShell forward-slash paths**. Manual install PowerShell snippet now uses forward slashes consistently.

(Items 8 to 15 are the BOOTSTRAP.md patches grouped under "Fix #12: BOOTSTRAP.md completeness" in the summary count of 12.)

## Flagged for user decision (no auto-fix possible)

These three items genuinely require user judgment. None block the install.

### Flag 1: Slash command porting

**What:** `home/reference/commands/` contains 60+ Claude Code slash commands plus a `gsd/` subset (~30 more). Codex has no analog.
**Why not auto-fixable:** The right answer depends on which commands the user actually invokes daily. Bulk-porting all 90+ would clutter `home/skills/` with rarely-used wrappers; bulk-dropping risks losing a command the user relies on.
**What user decides:** Pick the 5 to 10 commands you use most, port each to `home/skills/<name>/SKILL.md`. The reviewer / build / GSD families are largely redundant because the matching agents are already converted under `home/agents/`. Recommendation: skip these unless a specific command has unique non-agent logic.

### Flag 2: Subagent model retiering

**What:** All 46 source agents declared `model: sonnet` (or other Anthropic shorthand). Mapped to `gpt-5-codex` for every agent because Codex does not host Anthropic models. The original tag is preserved as a `[orig model: X]` prefix in each agent's `description` field.
**Why not auto-fixable:** Right tier per agent depends on live testing. A reviewer agent may be fine on `gpt-5` (cheaper); a planner may need `gpt-5-codex` reasoning. No way to know without measuring.
**What user decides:** After first run, use a few agents and decide which to retier. Edit each agent's `model = "..."` in `home/agents/<name>.toml`, then re-run the install script (or copy the file directly into `~/.codex/agents/`).

### Flag 3: Secret values

**What:** Three env vars (`TAVILY_API_KEY`, `N8N_HOSTINGER_API_KEY`, `N8N_CITYFLEET_API_KEY`) referenced by `config.toml` MCP servers. The `.env` template in BOOTSTRAP.md contains `replace_me_*` placeholders.
**Why not auto-fixable:** Secrets are user-supplied. The setup script cannot fetch them.
**What user decides:** Pull current values from the source machine's `windows-claude-code/SECRETS.md` (gitignored) and write them into `~/.codex/.env` (or `~/.codex/env.ps1` on Windows) per the BOOTSTRAP.md template. Both n8n keys are time-limited JWTs; rotate when they expire at the n8n instance's API key page.

## Sign-off

- All applicable audit categories ran.
- Twelve mechanical issues auto-fixed; second-pass re-validation confirms zero remaining issues in those categories.
- Three judgment-call items flagged with clear ask.
- `windows-claude-code/` checksum baseline unchanged across the audit run (2868 files, zero diffs).
- BOOTSTRAP.md self-completability gaps from the prior session are closed in the file itself.

Verdict: **YES.**
