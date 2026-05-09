# INSTALL_PROMPT — Paste this into Claude Code on the new Windows machine

## How to use

1. On the Windows machine, install Claude Code (one-liner): open PowerShell, run `npm install -g @anthropic-ai/claude-code` (after installing Node.js from https://nodejs.org). Or: install Git for Windows from https://git-scm.com first, clone this repo, then run `npm install -g @anthropic-ai/claude-code` in the cloned dir.

2. `git clone https://github.com/ryan-magno-braendz/claude-set-up.git`
3. `cd claude-set-up`
4. Open Claude Code in that directory: `claude`
5. Paste **everything inside the code block below** as your first message
6. Have your `SECRETS.md` ready to paste when Claude asks for it (you transferred it privately — 1Password, Bitwarden, Signal, encrypted note)

---

## The prompt

```
You are setting up Claude Code on a fresh Windows machine using this repo
(https://github.com/ryan-magno-braendz/claude-set-up). Execute the install
end to end. Be methodical, verify each step, and stop only when you genuinely
need me (transferring secrets, GitHub auth). Use TodoWrite to track progress.

================================================================
PRE-FLIGHT — verify environment before doing anything
================================================================

1. Confirm OS:
   - Run: `$env:OS` should equal "Windows_NT"
   - If not Windows, stop and tell me

2. Confirm working directory:
   - Verify `bootstrap.ps1`, `render-templates.ps1`, `claude/` directory,
     `plugins.lock.json`, and `marketplaces.lock.json` all exist in the
     current directory
   - If not, tell me to cd into the cloned `claude-set-up` repo

3. Confirm shell is PowerShell (not cmd or Git Bash):
   - Run: `$PSVersionTable.PSVersion`
   - If it errors, tell me to relaunch you from PowerShell

4. Confirm winget is available:
   - Run: `winget --version`
   - If missing, tell me to install "App Installer" from the Microsoft
     Store, then relaunch

================================================================
STEP 1 — Run bootstrap.ps1 (installs prereqs + Claude Code + plugins)
================================================================

Run:
  powershell -ExecutionPolicy Bypass -File bootstrap.ps1

This installs (idempotently):
  - Git for Windows (provides bash, sed, awk, grep used by hooks)
  - Node.js LTS
  - Python 3.12
  - GitHub CLI (gh)
  - jq
  - PowerShell 7
  - @anthropic-ai/claude-code (npm global)
  - Copies claude/ -> %USERPROFILE%\.claude\
  - Registers 8 plugin marketplaces
  - Installs 7 plugins from plugins.lock.json

Watch the output. If any winget install asks for confirmation, tell me.

After it finishes, verify:
  - `claude --version`           -> prints a version
  - `Test-Path "$env:USERPROFILE\.claude\settings.template.json"` -> True
  - `Test-Path "$env:USERPROFILE\.claude\agents"`                 -> True
  - `Test-Path "$env:USERPROFILE\.claude\skills\gstack"`          -> True
  - `claude plugin list` -> 7 plugins listed

If any plugin install failed, retry the failed ones:
  claude plugin install <plugin-id>

================================================================
STEP 2 — Receive SECRETS.md and populate .env
================================================================

Stop and ask me:

  "I need the contents of SECRETS.md (the file you transferred privately
   from the old macOS machine). Paste the entire 'Required env vars' and
   'Optional env vars' sections here. If you don't have it yet, tell me
   and I'll wait."

When I paste it, extract the KEY=VALUE lines for at minimum these three
required vars:
  TAVILY_API_KEY
  N8N_HOSTINGER_API_KEY
  N8N_CITYFLEET_API_KEY

Plus any optional ones I provided:
  BRAVE_API_KEY, FIRECRAWL_API_KEY, EXA_API_KEY, GEMINI_API_KEY,
  OPENAI_API_KEY, FAL_KEY, BROWSERBASE_API_KEY, etc.

Write them as a clean .env file to:
  $env:USERPROFILE\.claude\.env

Format: one KEY=VALUE per line, no quotes, no surrounding whitespace.
Skip any var I left blank.

After writing, verify the file exists and contains the three required keys
(do NOT echo the values back — keep them out of the conversation).

================================================================
STEP 3 — Render templates (substitute .env into settings.json + .mcp.json)
================================================================

Run:
  powershell -ExecutionPolicy Bypass -File render-templates.ps1

Verify:
  - `Test-Path "$env:USERPROFILE\.claude\settings.json"` -> True
  - `Test-Path "$env:USERPROFILE\.claude\.mcp.json"`     -> True
  - The rendered files contain NO `${...}` placeholders. Check with:
      Select-String -Path "$env:USERPROFILE\.claude\settings.json" -Pattern '\$\{'
      Select-String -Path "$env:USERPROFILE\.claude\.mcp.json"     -Pattern '\$\{'
    Both should return nothing.
  - Both files parse as valid JSON:
      Get-Content "$env:USERPROFILE\.claude\settings.json" | ConvertFrom-Json
      Get-Content "$env:USERPROFILE\.claude\.mcp.json"     | ConvertFrom-Json

If any placeholder remains, the .env is missing that var. Tell me which.

================================================================
STEP 4 — Authenticate GitHub
================================================================

Run:
  gh auth login

This opens a browser flow. Walk me through it: select GitHub.com -> HTTPS
-> Yes (auth git) -> Login with browser -> copy the one-time code,
paste in browser.

Verify:
  gh auth status     # should show "Logged in to github.com"

================================================================
STEP 5 — Anthropic auth (manual — outside this session)
================================================================

This Claude Code instance is already authenticated (you're running in it).
Skip this step unless I tell you the auth is missing.

If auth is missing, tell me to:
  1. Exit this Claude session
  2. Run `claude` from a fresh PowerShell window
  3. Follow the login prompt
  4. Come back and resume here

================================================================
STEP 6 — Smoke test the install
================================================================

Run these and report results:

  claude --version
  claude mcp list             # expect: tavily, n8n
  claude plugin list          # expect 7 plugins enabled
  Get-ChildItem "$env:USERPROFILE\.claude\skills" | Measure-Object
                              # expect 70+ skill directories
  Get-ChildItem "$env:USERPROFILE\.claude\agents" -Filter *.md | Measure-Object
                              # expect 48 agent files
  Get-ChildItem "$env:USERPROFILE\.claude\hooks" | Measure-Object
                              # expect 23+ hook files

Also test that hooks work by running a hook script directly:
  bash "$env:USERPROFILE\.claude\hooks\scan-secrets.sh" < $null
  # Should exit cleanly (it expects stdin; piping null is fine)

If `bash` is not found, Git for Windows isn't on PATH yet. Tell me to
restart PowerShell and re-run this step.

================================================================
STEP 7 — Optional: build gstack browser engine
================================================================

The gstack skill ships without compiled binaries (we excluded the 117 MB
build artifact from the repo). To enable browser features (`/browse`, QA
testing), build it:

  winget install Oven-sh.Bun
  cd "$env:USERPROFILE\.claude\skills\gstack"
  bun install
  bun run build

This takes a few minutes. If I haven't asked for it, skip this step and
just tell me how to do it later.

================================================================
STEP 8 — Final report
================================================================

Print a summary:
  [x] Prereqs installed
  [x] Claude Code installed (version: ...)
  [x] %USERPROFILE%\.claude\ populated
  [x] Plugins: N installed
  [x] Templates rendered
  [x] GitHub authenticated as: ...
  [ ] gstack browser engine built (skipped/done)
  [ ] Anthropic auth (verified by you running this session)

Then remind me:

  1. The `tmux`-dependent features (subagent dispatching via tmux,
     claude-session-driver) are degraded on native Windows. See SETUP.md
     compatibility matrix. Use WSL2 if you need them.
  2. The CLAUDE.md still references the macOS Obsidian Vault path. The
     vault rules will be inert (harmless) until I install Obsidian and
     update the path.
  3. Both n8n JWTs are time-limited — rotate them when convenient.
  4. Delete SECRETS.md from any transfer location now that it's installed.

================================================================
ERROR HANDLING
================================================================

- If `bootstrap.ps1` fails on a winget install: retry that single
  install manually, then re-run bootstrap.ps1 (it's idempotent).
- If `claude plugin install` fails for a plugin: capture the error,
  show me, and try `claude plugin marketplace add <repo>` first (the
  marketplace registration may have failed silently).
- If `render-templates.ps1` complains the .env is missing: re-check
  STEP 2.
- If hooks fail at runtime later (after restart): the most likely cause
  is `$HOME` not resolving in PowerShell. Hooks expect Git Bash. If a
  hook breaks, run it manually under Git Bash to isolate.

Don't skip verification. Don't claim "done" if a verification fails —
investigate, fix, and retry. Show me real output, not summaries.
```

---

## What this does end-to-end

1. Verifies you're on Windows in PowerShell with winget
2. Runs `bootstrap.ps1` — installs all system prereqs + Claude Code + plugins, copies config
3. Pauses and asks you for `SECRETS.md` content; writes `%USERPROFILE%\.claude\.env`
4. Renders templates → real `settings.json` + `.mcp.json`
5. Walks you through `gh auth login`
6. Smoke tests the install (mcp list, plugin list, skill/agent counts, bash hook test)
7. Optionally builds the `gstack` browser engine
8. Final summary + reminders about rotation, vault, tmux degradation

## Notes

- The Claude Code session you paste this into must be authenticated to Anthropic already. If it isn't, run `claude` once from a fresh PowerShell to authenticate, then come back.
- The prompt explicitly tells Claude not to echo your secret values back into the conversation — but pasted text still flows through context. Treat the values as compromised after pasting and rotate when convenient.
- This prompt is designed for a fresh machine. On a re-install or update, just run `git pull` + `powershell -ExecutionPolicy Bypass -File bootstrap.ps1` — no need to re-paste this prompt.
