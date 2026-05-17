# Codex Setup From Claude Code

## What this is

A self-contained Codex CLI configuration derived from a working Claude Code (CC) setup. Running the install script copies everything in `home/` into your user `~/.codex/` directory: an `AGENTS.md` global instruction file, a `config.toml` with feature flags and MCP servers, hooks, layered coding rules, 69 skills, and 46 subagent definitions.

What this folder does install:
- `AGENTS.md` (global instructions, with `CLAUDE.md` kept as fallback).
- `config.toml` with three MCP servers (tavily, two n8n flavors), feature flags for hooks and skills, project doc fallback to `CLAUDE.md`.
- `hooks.json` plus the script files under `hooks/` for the four Codex-supported events (SessionStart, Stop, PreToolUse, PostToolUse).
- 69 skills under `skills/`, all in directory form with `SKILL.md` plus optional assets.
- 46 subagent TOMLs under `agents/`.
- `rules/` (common plus per-language guidance).
- `memory/` (reference, Codex does not auto-load these; the global rules tell the assistant when to read them).
- `reference/` (slash commands, plugin scaffolding from CC that has no Codex analog; kept for human inspection).

What this folder does not install:
- The Codex CLI itself. Install separately.
- API keys. Set them as environment variables before first run.

## Windows Prerequisites

Install these before running `scripts/setup-codex.ps1`:

```powershell
winget install Git.Git
winget install OpenJS.NodeJS.LTS
npm install -g @openai/codex
```

Restart PowerShell after installing Git so `bash` is on `PATH`.

Secrets are not bundled. After install, run:

```powershell
codex login
$TavilyApiKey = Read-Host "Enter TAVILY_API_KEY"
$N8nHostingerApiKey = Read-Host "Enter N8N_HOSTINGER_API_KEY"
$N8nCityfleetApiKey = Read-Host "Enter N8N_CITYFLEET_API_KEY"
[Environment]::SetEnvironmentVariable("TAVILY_API_KEY", $TavilyApiKey, "User")
[Environment]::SetEnvironmentVariable("N8N_HOSTINGER_API_KEY", $N8nHostingerApiKey, "User")
[Environment]::SetEnvironmentVariable("N8N_CITYFLEET_API_KEY", $N8nCityfleetApiKey, "User")
```

## Prerequisites

1. **Codex CLI.** Install per the official instructions. Verify with `codex --version`.
2. **Skills feature available.** Codex 2.x with skills enabled. Older builds may name the flag `experimental_skills` instead of `skills`. The Troubleshooting section shows how to detect and switch.
3. **Bash on Windows.** Several hook scripts are POSIX shell. On Windows, install Git Bash and ensure `bash` is on PATH. `winget install Git.Git`, then add `C:/Program Files/Git/bin` to PATH.
4. **Node.js.** Three hooks are `.js` files run via `node`. Install Node 18 or newer.
5. **Backup of existing `~/.codex/`.** The install script does this automatically (`~/.codex.bak.<timestamp>`), but a manual backup is wise.

## One-command install (with dry run first)

The recommended flow runs a dry run before the real install. The dry run prints every file that would be copied and the resulting target tree, but writes nothing.

macOS or Linux:
```bash
# 1. From this directory (codex-from-claude/), preview:
./scripts/setup-codex.sh --dry-run

# 2. Inspect the printed file list and target tree.

# 3. If the preview looks right, run the real install:
./scripts/setup-codex.sh
```

Windows (PowerShell):
```powershell
# 1. From this directory (codex-from-claude/), preview:
.\scripts\setup-codex.ps1 -DryRun

# 2. Inspect the printed file list and target tree.

# 3. If the preview looks right, run the real install:
.\scripts\setup-codex.ps1
```

Both scripts:
- Back up any existing `~/.codex/` to `~/.codex.bak.<timestamp>`.
- Copy `home/` into `~/.codex/`.
- Make hook scripts executable.
- Print a file count check at the end (source vs target).

## Manual install

If you want to inspect each step, run these commands instead.

```bash
# 1. Back up
mv "$HOME/.codex" "$HOME/.codex.bak.$(date +%Y%m%d-%H%M%S)" 2>/dev/null || true

# 2. Create target
mkdir -p "$HOME/.codex"

# 3. Copy contents (not the home/ wrapper itself)
cp -R home/. "$HOME/.codex/"

# 4. Make hooks executable
chmod +x "$HOME/.codex/hooks"/*.sh "$HOME/.codex/hooks"/*.js
```

PowerShell equivalent:
```powershell
$ts = Get-Date -Format 'yyyyMMdd-HHmmss'
if (Test-Path "$env:USERPROFILE/.codex") {
    Move-Item "$env:USERPROFILE/.codex" "$env:USERPROFILE/.codex.bak.$ts"
}
New-Item -Path "$env:USERPROFILE/.codex" -ItemType Directory -Force | Out-Null
Copy-Item -Path 'home/*' -Destination "$env:USERPROFILE/.codex" -Recurse -Force
```

## Set environment variables

The MCP servers in `config.toml` reference three env vars:

| Variable | Used by | Where to get it |
|---|---|---|
| `TAVILY_API_KEY` | tavily MCP | tavily.com dashboard |
| `N8N_HOSTINGER_API_KEY` | n8n_hostinger MCP | the SECRETS.md transferred from the source machine |
| `N8N_CITYFLEET_API_KEY` | n8n_cityfleet MCP | same SECRETS.md |

### Concrete `.env` template

Save the snippet below as `~/.codex/.env` and source it from your shell rc. Replace each `replace_me` with the real value.

```bash
# ~/.codex/.env
# Source this from .bashrc / .zshrc:  set -a; source "$HOME/.codex/.env"; set +a

TAVILY_API_KEY=replace_me_tavily
N8N_HOSTINGER_API_KEY=replace_me_n8n_hostinger_jwt
N8N_CITYFLEET_API_KEY=replace_me_n8n_cityfleet_jwt
```

PowerShell equivalent (`~/.codex/env.ps1`, dot-source from `$PROFILE`):

```powershell
# ~/.codex/env.ps1
# Dot-source from $PROFILE:  . "$HOME/.codex/env.ps1"

$env:TAVILY_API_KEY = 'replace_me_tavily'
$env:N8N_HOSTINGER_API_KEY = 'replace_me_n8n_hostinger_jwt'
$env:N8N_CITYFLEET_API_KEY = 'replace_me_n8n_cityfleet_jwt'
```

Both n8n keys are time-limited JWTs and need rotation periodically. Rotate at the n8n instance's API key page, then update the env files.

## Verification

Run the commands below in order. Each shows what success looks like. If your output diverges, jump to the matching Troubleshooting entry.

### 1. Codex CLI installed
```bash
codex --version
```
Expected output:
```
codex 2.1.0
```
Fail: command not found means Codex CLI itself is missing. Install per official instructions, then retry.

### 2. AGENTS.md visible
Primary command (works on builds that expose the helper):
```bash
codex agents-md
```
Fallback (always works, on every Codex build and from any shell):
```bash
head -20 ~/.codex/AGENTS.md
```
Expected output (first three lines):
```
# AGENTS.md

This file is read by Codex CLI on session start and provides global instructions for every Codex session run from this user's machine. It mirrors the role of `~/.claude/CLAUDE.md` under Claude Code.
```

### 3. Skills loaded
Inside a Codex session, type:
```
/skills
```
Expected output (truncated):
```
Available skills:
  10x-thinking            Higher-leverage problem framing.
  agentic-engineering     Patterns for AI agent code.
  autoresearch            Run autonomous 3-round web research.
  ...
  (69 entries total)
```
Fail: empty list means skills feature flag is wrong. See "Skills not loading" below.

### 4. Hooks fire
In a Codex session, ask it to list a directory via Bash. Then in another shell:
```bash
tail -3 ~/.codex/hooks/command-log.sh.log 2>/dev/null || ls -lt ~/.codex/logs/ 2>/dev/null | head -5
```
Expected: a recent timestamped entry referencing the `ls` command. The exact log path depends on what `command-log.sh` writes. The bare assertion is: the file modification time of any `~/.codex/hooks/*.log` should advance when you run a Bash command in Codex.
Fail: nothing changes. See "Hooks silent" below.

### 5. MCP servers reachable
Inside a Codex session, type:
```
/mcp
```
Expected output:
```
MCP servers:
  tavily          (stdio) tavily-mcp@latest
  n8n_hostinger   (stdio) n8n-mcp
  n8n_cityfleet   (stdio) n8n-mcp@latest
```
Fail: server listed but tool calls hang. See "MCP server timing out" below.

### Expected file counts after install

```
~/.codex/AGENTS.md           1 file
~/.codex/CLAUDE.md           1 file
~/.codex/config.toml         1 file
~/.codex/hooks.json          1 file
~/.codex/hooks/             17 script files (.sh and .js)
~/.codex/skills/            69 entries at depth 1 (some are symlinks into gstack/)
~/.codex/agents/            46 .toml files
~/.codex/rules/             44 files (common plus 6 language folders)
~/.codex/memory/            10 files
~/.codex/reference/         (variable; manual review queue)
```
Quick sanity check:
```bash
test -f ~/.codex/AGENTS.md && \
echo "agent tomls: $(ls ~/.codex/agents/*.toml | wc -l)" && \
echo "skills: $(ls ~/.codex/skills/ | wc -l)" && \
echo "hook scripts: $(ls ~/.codex/hooks/ | wc -l)"
```
Expected:
```
agent tomls:       46
skills:       69
hook scripts:       17
```

## Troubleshooting

### Skills not loading

Symptoms: `/skills` shows nothing, or skill names do not autocomplete.

Detect which flag name your Codex build expects:
```bash
codex --version
# 2.0+ uses [features] skills = true
# 1.x uses [features] experimental_skills = true
```

If your build is 1.x, edit `~/.codex/config.toml`:
```toml
# Replace this line:
[features]
skills = true

# With this:
[features]
experimental_skills = true
```

Other checks:
1. Confirm each skill is a directory containing `SKILL.md`. Codex requires directory form. Flat-file skills are silently ignored.
2. Check the YAML frontmatter at the top of `SKILL.md`. The `name` field must match the directory name.
3. Restart Codex. Skill enumeration is cached at session start.

### Hooks silent

Symptoms: file edits or tool calls do not trigger any hook output.

1. Confirm `[features] codex_hooks = true` in `~/.codex/config.toml`.
2. Confirm `~/.codex/hooks.json` parses as JSON: `cat ~/.codex/hooks.json | jq .`. Output should be the file as a JSON tree, not a parse error.
3. Confirm hook script files are executable: `ls -l ~/.codex/hooks/*.sh`. The `x` bit must be set.
4. Run a hook manually to confirm it does not error in your environment: `bash ~/.codex/hooks/command-log.sh`.
5. On Windows, confirm `bash` is on PATH: `bash --version`. If not, Git Bash is missing.
6. Check Codex logs (typically `~/.codex/logs/`) for hook errors.

#### Hook schema variants (most common silent-hooks cause)

Codex hook JSON has shipped in two shapes across versions. This setup uses the **nested `hooks` array** shape that matches Claude Code. If your build expects the **flat** shape, hooks parse silently but never fire.

Detect by reading any one event from `~/.codex/hooks.json`:
```bash
jq '.hooks.PreToolUse[0]' ~/.codex/hooks.json
```
If the result has a `hooks` array nested inside, you are on the nested shape (this setup's default).

If your build complains in `~/.codex/logs/` about an unknown field or fails silently, transform to the flat shape:

Nested (current, this setup):
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          { "type": "command", "command": "bash $HOME/.codex/hooks/scan-secrets.sh", "timeout": 5 }
        ]
      }
    ]
  }
}
```

Flat (alternate):
```json
{
  "hooks": [
    {
      "event": "PreToolUse",
      "matcher": "Edit|Write",
      "command": "bash $HOME/.codex/hooks/scan-secrets.sh",
      "timeout": 5
    }
  ]
}
```

A one-shot `jq` transform from nested to flat:
```bash
jq '{
  hooks: [
    .hooks
    | to_entries[]
    | .key as $event
    | .value[]
    | (.matcher // null) as $matcher
    | .hooks[]
    | { event: $event, matcher: $matcher, command: .command, timeout: (.timeout // 30) }
  ]
}' ~/.codex/hooks.json > ~/.codex/hooks.flat.json
mv ~/.codex/hooks.flat.json ~/.codex/hooks.json
```

### MCP server timing out

Symptoms: `/mcp` lists the server but tool calls hang or return errors.

1. Confirm the env var resolves. Run `echo $TAVILY_API_KEY` (or `echo $env:TAVILY_API_KEY` in PowerShell). Empty value means the variable is not loaded.
2. Run the MCP command manually to see what happens: `npx -y tavily-mcp@latest`.
3. For the two n8n flavors, confirm the JWT has not expired. Decode with `jwt.io` or:
   ```bash
   echo "$N8N_HOSTINGER_API_KEY" | jq -R 'split(".") | .[1] | @base64d | fromjson'
   ```
4. For HTTP-transport MCPs (none active by default; see `reference/mcp-configs/` for the optional catalog), confirm the URL is reachable.

### `bash` not found on Windows

Hooks fail with `command not found`. Install Git for Windows, then add Git Bash to PATH:
```powershell
winget install Git.Git
# Reopen PowerShell, then verify:
bash --version
```

### Restoring a previous install

The setup script saves `~/.codex/` as `~/.codex.bak.<timestamp>` before overwriting. Restore with:
```bash
rm -rf ~/.codex
mv ~/.codex.bak.<timestamp> ~/.codex
```
PowerShell:
```powershell
Remove-Item -Recurse -Force "$HOME/.codex"
Move-Item "$HOME/.codex.bak.<timestamp>" "$HOME/.codex"
```

## What was dropped

A short list of source items that did not make it across:

- The `Notification` hook event (Codex does not expose it).
- 60+ Claude Code slash commands and the `gsd/` subset (no direct Codex equivalent; preserved under `home/reference/commands/` for the user to port manually as skills or prompts if desired).
- Plugin scaffolding (`ecc/`, `get-shit-done/`, `teams/`, `marketplace.json`, `plugin.json`, `package.json`, `plugins.lock.json`, `marketplaces.lock.json`, `statusline.js`). All Anthropic-Claude-Code-specific. Preserved under `home/reference/` where applicable, dropped where not.
- `auto-memory` (Codex does not have an auto-loaded memory). The contents of `~/.claude/memory/` are copied to `~/.codex/memory/` as reference; AGENTS.md tells the assistant when to read them.

The full per-artifact disposition is in `MIGRATION_REPORT.md`.
