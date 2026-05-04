# SETUP — Windows Native Install Guide

This repo replicates the macOS Claude Code setup at `~/.claude/` onto a Windows machine at `%USERPROFILE%\.claude\`. Bootstrap is two scripts: install + render-templates.

> **Caveat read this first.** Several tools in this setup assume POSIX shell. On native Windows, hooks run via Git Bash (auto-installed) and most things work — but a few features are degraded. See the **Compatibility Matrix** at the bottom.

---

## Prerequisites

- Windows 10 (build 1709+) or Windows 11
- Admin / elevated PowerShell
- `winget` available (ships with Windows 10 1809+ via "App Installer" from Microsoft Store)
- ~5 GB disk space (mostly for Node, Python, plugins after install)

---

## Install

### Step 1 — Clone

```powershell
git clone https://github.com/ryan-magno-braendz/claude-set-up.git
cd claude-set-up
```

(If `git` isn't installed yet, install via `winget install Git.Git` first, or download from git-scm.com — bootstrap installs it on its own pass too.)

### Step 2 — Run bootstrap

```powershell
powershell -ExecutionPolicy Bypass -File bootstrap.ps1
```

What it does:
1. Installs Git for Windows, Node.js LTS, Python 3.12, GitHub CLI, jq, PowerShell 7
2. Installs Claude Code (`npm install -g @anthropic-ai/claude-code`)
3. Copies `claude/` into `%USERPROFILE%\.claude\`
4. Registers all 8 plugin marketplaces
5. Installs all 7 plugins from `plugins.lock.json`
6. (Skipped if no `.env` yet) Renders templates → `settings.json` and `.mcp.json`

### Step 3 — Receive `SECRETS.md` privately

The source machine generates `SECRETS.md` (gitignored). Transfer it to the new machine via 1Password / Bitwarden / Signal / encrypted note. **Do not email it. Do not commit it.**

### Step 4 — Create `.env` file

Create `%USERPROFILE%\.claude\.env` with the values from `SECRETS.md`:

```env
TAVILY_API_KEY=tvly-dev-...
N8N_HOSTINGER_API_KEY=eyJhbGci...
N8N_CITYFLEET_API_KEY=eyJhbGci...

# Optional (only fill what you actually use):
BRAVE_API_KEY=
FIRECRAWL_API_KEY=
EXA_API_KEY=
GEMINI_API_KEY=
OPENAI_API_KEY=
```

### Step 5 — Render templates

```powershell
powershell -ExecutionPolicy Bypass -File render-templates.ps1
```

This produces real `settings.json` and `.mcp.json` from the templates with secrets substituted.

### Step 6 — Authenticate

```powershell
gh auth login         # GitHub CLI
claude                # First run prompts for Anthropic login
```

### Step 7 — Verify

```powershell
claude --version
claude mcp list       # Should list tavily, n8n
claude plugin list    # Should list 7 plugins
```

---

## Updating

When the source machine changes, sync the repo:

```bash
# On macOS source machine
cd ~/Documents/Projects/Claude\ Set-up/claude-set-up
rsync -av --delete --exclude-from='.gitignore' ~/.claude/ claude/
git add -A && git commit -m "sync: <date>" && git push
```

Then on Windows:

```powershell
cd path\to\claude-set-up
git pull
powershell -ExecutionPolicy Bypass -File bootstrap.ps1   # re-runs idempotently
```

---

## Compatibility Matrix — Windows native quirks

| Feature | Status on native Windows | Notes |
|---|---|---|
| Claude Code CLI | Works | Native binary via npm. |
| MCP servers (tavily, n8n) | Works | npx / standalone binaries; render-templates substitutes secrets. |
| Hooks (`*.sh` scripts) | Works via Git Bash | Settings paths use `$HOME` so Git Bash resolves them. |
| Hooks (`*.js` Node scripts) | Works | Plain Node.js — no shell needed. |
| Skills (most) | Works | Markdown + light glue code. |
| Plugins (7 installed) | Works | Plugin runtime is JS-only. |
| `tmux`-based features | **Degraded** | `teammateMode: "tmux"` in settings — no native tmux. Either: install WSL2 and run claude there, or accept that team sessions won't spawn. |
| `superpowers:dispatching-parallel-agents` | **Degraded** | Uses tmux; falls back to sequential. |
| `claude-session-driver` | **Degraded** | Manages multiple Claude sessions; tmux-dependent. |
| `ao` (Agent Orchestrator) | **Likely broken** | Bash-heavy; not in this repo since you don't have a global install. Use WSL2 if needed. |
| `gsd` parallel workflows | **Partially degraded** | Sequential GSD works. Parallel waves require subagents which work fine; only tmux-based variants degrade. |
| `voiceEnabled: true` | Unknown | macOS-specific TTS likely. Ignore — purely cosmetic. |
| `gstack` browser skill | Works | Playwright runs natively on Windows. |
| Statusline (`statusline.js`) | Works | Plain Node.js. |
| Path handling in CLAUDE.md | Inert | References to `/Users/gabrielmagno/Documents/Obsidian-Vault/` won't resolve — vault rules become no-ops, harmless. |

### If you want full feature parity

Install **WSL2 + Ubuntu** alongside (`wsl --install`), then re-run the bootstrap inside WSL using `bootstrap.sh` (not yet committed — straightforward to write later). The macOS bash setup transplants 1:1 onto WSL.

You can use both: native Windows for general coding, WSL for tmux-heavy orchestration.

---

## Troubleshooting

### `claude` command not found after bootstrap
Open a new PowerShell window — npm global path may not be on the current session's PATH.

### Hooks fail with "command not found: bash"
Git for Windows install didn't add bash to PATH. Reinstall with the option **"Use Git and optional Unix tools from the Command Prompt"**.

### `jq` not found
Install manually: `winget install jqlang.jq` then restart shell.

### Plugin install fails for `n8n-as-code`
Confirm `marketplaces.lock.json` has `EtienneLescot/n8n-as-code` (it does in this repo).

### MCP server fails to start with auth error
`%USERPROFILE%\.claude\.env` is missing or `render-templates.ps1` wasn't run after editing `.env`. Re-run it, restart Claude Code.

### Vault-related skills do nothing
Expected. The vault path `/Users/gabrielmagno/Documents/Obsidian-Vault/` doesn't exist on the new machine. The rules in `CLAUDE.md` become inert. To re-enable, install Obsidian, recreate the vault, and update the path in `CLAUDE.md`.

### "Permission denied" when running scripts
Use `powershell -ExecutionPolicy Bypass -File <script>.ps1` rather than calling directly.

### Want to start fresh
Delete `%USERPROFILE%\.claude\` entirely, then re-run bootstrap.

---

## What got copied

```
claude/
├── CLAUDE.md, AGENTS.md, README.md, statusline.js
├── settings.template.json (rendered → settings.json with .env)
├── .mcp.template.json     (rendered → .mcp.json with .env)
├── settings.local.template.json
├── agents/         (48 agents)
├── commands/       (62 commands incl. /gsd:*)
├── hooks/          (23 hook scripts)
├── rules/          (common + per-language rules)
├── skills/         (70 custom skills)
├── memory/         (your auto-memory — copied to new machine)
├── ecc/            (Everything Claude Code config)
├── scripts/, get-shit-done/, teams/, mcp-configs/
└── .cursor/, .codex/, .opencode/, .agents/
```

Excluded (regenerates automatically): `projects/`, `sessions/`, `todos/`, `tasks/`, `cache/`, `paste-cache/`, `shell-snapshots/`, `telemetry/`, `logs/`, `file-history/`, `ide/`, `session-env/`, `debug/`, `backups/`, `homunculus/` (per-project state), `plugins/` (reinstalled by bootstrap).
