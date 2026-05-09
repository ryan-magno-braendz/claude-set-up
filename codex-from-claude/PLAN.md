# Migration Plan: Claude Code -> Codex CLI

Date: 2026-05-09
Author: Claude (planning phase)
Status: Approved by self-review, ready to execute

## 1. Inventory

Source tree: repo root (current state, before any moves).

### Loose at root (will move into `windows-claude-code/`)
- `README.md` (existing CC repo readme; will be replaced at root with new top-level README)
- `INSTALL_PROMPT.md`, `SETUP.md`
- `SECRETS.example.md`, `SECRETS.md` (gitignored)
- `bootstrap.ps1`, `render-templates.ps1`
- `plugins.lock.json`, `marketplaces.lock.json`
- `.gitignore` (CC-specific exclusions; new gitignore at root after migration)
- `.planning/`, `.letta/`
- `claude/` (the full CC payload mirror)

### Inside `claude/` (the payload to port)
- `CLAUDE.md`, `AGENTS.md`, `README.md`, `PLUGIN_SCHEMA_NOTES.md`
- `settings.template.json` (contains hooks, mcpServers, env, permissions, plugin enablement)
- `.mcp.template.json` (project-level MCPs: tavily, n8n hostinger)
- `settings.local.template.json`
- `agents/` -- 46 markdown agent definitions
- `skills/` -- 69 directory-form skills (all already directory-form; gstack has nested children)
- `commands/` -- 60 CC slash commands plus a `gsd/` subfolder (~30 more)
- `hooks/` -- 20 scripts (bash + node), plus README and disabled/removed files
- `rules/` -- common + 6 language-specific (cpp, csharp, java, python, rust, typescript)
- `memory/` -- auto-memory directory
- `mcp-configs/mcp-servers.json` -- 23-entry catalog (reference, not active)
- `ecc/`, `get-shit-done/`, `teams/`, `scripts/` -- CC plugin auxiliary
- `marketplace.json`, `plugin.json`, `package.json`, `gsd-file-manifest.json`
- `statusline.js`

### Hook events present (settings.template.json)
- `SessionStart` (3 hook entries) -> Codex supports
- `Stop` (1 entry, 2 commands) -> Codex supports
- `Notification` (1 entry, 2 commands) -> Codex DOES NOT support, DROP
- `PostToolUse` (4 entries) -> Codex supports
- `PreToolUse` (6 entries) -> Codex supports

### MCP servers (active, from templates)
1. `n8n` (cityfleet variant in settings.template.json env)
2. `n8n` (hostinger variant in .mcp.template.json)
3. `tavily` (in .mcp.template.json)

## 2. Classification

| Item | Disposition | Reason |
| --- | --- | --- |
| `CLAUDE.md` (claude/) | MECHANICAL | Becomes `AGENTS.md`, content is universal (rules-based) |
| `AGENTS.md` (claude/) | MECHANICAL | Already Codex-friendly, copy verbatim, merge with above |
| `agents/*.md` (46) | MECHANICAL | Convert frontmatter+body to TOML (name, prompt, model, sandbox_mode) |
| `skills/<name>/` (69) | MECHANICAL | Copy directory verbatim, all already directory-form |
| `hooks/*.sh` and `*.js` | MECHANICAL | Copy verbatim into `home/hooks/`, paths in hooks.json updated |
| Hook events: SessionStart, Stop, PreToolUse, PostToolUse | MECHANICAL | Filter into Codex-supported set in `home/hooks.json` |
| Hook event: Notification | DROP | Codex does not expose Notification event |
| MCP servers (tavily, n8n x2) | MECHANICAL | Convert to `[mcp_servers.<name>]` TOML blocks in config.toml |
| `rules/` | MECHANICAL | Copy verbatim into `home/rules/`, AGENTS.md references |
| `memory/` | MANUAL | Codex has no auto-memory; copy as reference, AGENTS.md tells reader to read it |
| `commands/` (60+gsd) | MANUAL | CC slash commands; no direct Codex equivalent; copy as reference for human authoring |
| `ecc/`, `get-shit-done/`, `teams/`, `scripts/` | MANUAL | CC plugin scaffolding; copy verbatim as reference; flag in report |
| `mcp-configs/mcp-servers.json` | MANUAL | 23-entry catalog of optional MCPs; provide as commented TOML appendix in config.toml |
| `marketplace.json`, `plugin.json`, `package.json`, `plugins.lock.json`, `marketplaces.lock.json`, `statusline.js`, `gsd-file-manifest.json` | DROP | CC-plugin-specific; no Codex analog |
| `bootstrap.ps1`, `render-templates.ps1`, `INSTALL_PROMPT.md`, `SETUP.md`, `SECRETS*.md` | KEPT (in windows-claude-code/) | Original Windows CC bootstrap; preserved verbatim |

DROP justifications all rest on: the artifact is specific to Anthropic's Claude Code plugin/marketplace system, which Codex does not implement.

## 3. Tool choice

**Hand-port.** Reasons:
1. Source lives at `claude/`, not `.claude/`. cc2codex expects a live `~/.claude/` install layout.
2. cc2codex has no built-in support for the bespoke `MIGRATION_REPORT.md` format the constraints require.
3. Many items (commands, plugin-aux dirs) require human-judgement DROP/MANUAL classification that the tool would not get right.
4. Cross-platform path rewriting (`$HOME/.claude/hooks/x.sh` -> `$HOME/.codex/hooks/x.sh`) is a 1-line `sed` job; not worth installing a tool.

Fallback to cc2codex was considered and rejected (reasons above). No network call needed.

## 4. Folder layout (final)

```
.
├── README.md
├── windows-claude-code/        (original CC setup, byte-identical)
│   ├── README.md
│   ├── INSTALL_PROMPT.md
│   ├── SETUP.md
│   ├── SECRETS.example.md
│   ├── SECRETS.md              (gitignored)
│   ├── bootstrap.ps1
│   ├── render-templates.ps1
│   ├── plugins.lock.json
│   ├── marketplaces.lock.json
│   ├── .gitignore              (CC-specific)
│   ├── .planning/
│   ├── .letta/
│   └── claude/                 (full CC payload mirror)
└── codex-from-claude/
    ├── BOOTSTRAP.md
    ├── MIGRATION_REPORT.md
    ├── PLAN.md                 (this file, moved)
    ├── README.md
    ├── home/                   (mirrors target ~/.codex/)
    │   ├── AGENTS.md
    │   ├── CLAUDE.md           (fallback, byte-identical to source)
    │   ├── config.toml
    │   ├── hooks.json
    │   ├── hooks/              (script files, copied verbatim)
    │   ├── skills/             (69 directories)
    │   ├── agents/             (46 .toml files)
    │   ├── rules/              (verbatim copy)
    │   ├── memory/             (verbatim copy, reference)
    │   └── reference/          (commands/, ecc/, get-shit-done/, teams/, mcp-configs/ for human review)
    └── scripts/
        ├── setup-codex.ps1
        └── setup-codex.sh
```

Final repo root: `README.md`, `windows-claude-code/`, `codex-from-claude/`, plus `.git/` and a single `.gitignore` (hidden file, not counted as user-facing loose file).

## 5. Risks

1. **Codex hook schema drift.** Codex hooks.json schema has evolved across versions. We use the documented `{ event: [{ matcher, command, timeout }] }` shape. BOOTSTRAP.md has a troubleshooting note if a specific Codex version uses a different shape. (Manual review item.)
2. **Skill enablement flag.** Codex's skills feature flag name varies (`skills`, `experimental_skills`). config.toml sets `[features] skills = true` and BOOTSTRAP.md documents the alternative.
3. **MCP server `type: http` entries.** Some MCP servers in the catalog use HTTP transport; TOML representation is `transport = "http"` plus `url`. Active set (tavily, n8n) is stdio so not affected.
4. **Path semantics.** Codex hooks use POSIX paths even on Windows under Git Bash or WSL. Paths in hooks.json use `$HOME/.codex/hooks/...`. setup-codex.ps1 ensures Git Bash is on PATH or provides a manual fallback.
5. **Memory content.** Codex has no auto-memory loader. Memory entries become reference docs that AGENTS.md links to but does not auto-load. Long-context users may need to paste them manually.
6. **Commands directory.** 60+ slash commands are MANUAL; user must decide which to convert to skills, prompts, or drop. Listed as a queue in MIGRATION_REPORT.md.

## Self-review checks

- [x] Inventory covers every loose-at-root item and every claude/ subdirectory observed via `ls`.
- [x] Every item has a disposition (KEPT/MECHANICAL/MANUAL/DROP) with a reason.
- [x] No item is invented; everything came from the actual source tree.
- [x] Folder layout matches the constraint "exactly README.md, windows-claude-code/, codex-from-claude/" at the visible level.
- [x] Hooks classification matches the documented Codex supported event set.
- [x] Tool-choice decision documented.
- [x] Risks identified with mitigation plan.

Plan is internally consistent. Proceeding to execution.
