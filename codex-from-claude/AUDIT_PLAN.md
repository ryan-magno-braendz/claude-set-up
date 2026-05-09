# Audit Plan

Date: 2026-05-09
Scope: codex-from-claude/ (post-migration audit).
Source of truth for cross-check: windows-claude-code/ (must remain byte-identical).

## Categories

1. Repo structure (3 entries at root, no leftover artifacts).
2. windows-claude-code integrity (file count, checksum baseline preserved).
3. Independent inventory cross-check (skills, agents, hooks, MCP servers).
4. Skill family completeness (gsd, n8n, superpowers; per-family count comparison).
5. codex-from-claude file presence (BOOTSTRAP.md, MIGRATION_REPORT.md, PLAN.md, README.md, home/, scripts/).
6. AGENTS.md validity (non-empty, no Claude-specific tool refs that misdirect a Codex run).
7. config.toml validity (parses, required keys at top level, MCP servers shaped correctly).
8. hooks.json validity (parses, only Codex-supported events, forward-slash paths).
9. Skill audit (each top-level skill: directory form, valid frontmatter, name matches directory, description >= 10 chars).
10. Subagents audit (each .toml: parses, has name/prompt/model/sandbox_mode, name matches filename).
11. Setup scripts audit (presence, backup logic, file count check, --dry-run support, idempotent, forward-slash paths in .sh).
12. BOOTSTRAP.md completeness (prereqs, install, verification with expected output, troubleshooting with alternate shapes, env template, dry-run-first recipe, fallbacks for any hedged primary commands).
13. MIGRATION_REPORT.md internal consistency (totals match per-category sums, queue does not contradict tables).

## Tooling

| Tool | Available | Use |
|---|---|---|
| cc2codex | NOT installed | Manual cross-check substituted; absence logged in AUDIT_REPORT under category 3. |
| jq | yes | hooks.json validation |
| python3 + tomllib | yes | config.toml and 46 agent TOMLs |
| PyYAML | NOT installed (PEP 668 blocked) | Skill frontmatter validated by regex with manual handling for YAML block scalars |
| shellcheck | NOT installed | setup-codex.sh smoke-tested with `bash -n` and `--dry-run` execution |
| PSScriptAnalyzer | NOT available (macOS host) | setup-codex.ps1 reviewed by visual inspection only |

## Expected counts (claimed by MIGRATION_REPORT.md)

| Item | Claimed | Will verify |
|---|---|---|
| Skills | 69 (46 dir + 21 symlinks + 3 absolute-symlink resolutions) | yes, by listing |
| Subagents | 46 | yes |
| Hook events ported | 4 (SessionStart, Stop, PreToolUse, PostToolUse) | yes |
| Hook events dropped | 1 (Notification) | yes, by absence |
| Hook script files | 17 | yes |
| MCP servers active | 3 (tavily, n8n_hostinger, n8n_cityfleet) | yes |
| MCP servers in catalog | 23 | yes |
| Rules files | 44 | yes |
| Memory files | 10 | yes |

## Independent counts (filled during audit)

To be filled by audit pass.

## Risks identified up front

1. The 21 intra-tree skill symlinks point into `gstack/`. If `gstack/` changed structure, symlinks could break. Need to dereference and confirm.
2. Agent TOMLs were generated with `"""` triple-quote strings, which interpret escapes. Source markdown contains regex patterns and other backslashes that are not valid TOML escapes. Need to parse-validate every TOML.
3. Top-level keys after `[features]` section header in TOML scope under `[features]`, not at the top. Need to confirm `project_doc_fallback_filenames` parses at top level.
4. BOOTSTRAP.md was previously flagged with five gaps that should have been auto-fixed in the prior run. They must be fixed in this run, not flagged again.
5. A `.letta/` runtime directory may regenerate at root from the active Letta plugin during the audit session. Need a permanent fix (gitignore + delete) to prevent future regressions.

## Order of execution

1. Capture pre-audit checksums for windows-claude-code.
2. Run all 13 categories in parallel where independent. Log every check.
3. Apply all auto-fixes.
4. Re-run categories that had auto-fixes.
5. Confirm windows-claude-code byte-identical post-audit.
6. Write final AUDIT_REPORT.md with verdict YES or NO.
