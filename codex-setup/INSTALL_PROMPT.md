# INSTALL_PROMPT: paste this into Codex CLI on the Windows target machine

## How to use

1. Install prerequisites on Windows:
   ```powershell
   winget install Git.Git
   winget install OpenJS.NodeJS.LTS
   npm install -g @openai/codex
   ```
2. Restart PowerShell so Git Bash is on `PATH`.
3. Run `codex login`.
4. Copy or clone this repo onto the Windows machine.
5. Open PowerShell in the repo root, the directory containing `README.md` and `codex-setup/`.
6. Launch Codex from that directory:
   ```powershell
   codex
   ```
7. Paste everything inside the prompt block below.

---

## The prompt

```text
<goal>
Set up this Windows machine with the Codex configuration contained in the local repo. Use codex-setup as the source of truth. End state: $env:USERPROFILE\.codex contains a functional one-to-one mirror of the source setup. Native notification config, notify.sh, and the permission-request notification hook are intentionally excluded; the Stop ding hook is included. Verify the installed files immediately, then tell the user to restart Codex for skills, plugins, hooks, and MCP servers to load.
</goal>

<context>
The current working directory is the repo root. It should contain:
- README.md
- codex-setup/BOOTSTRAP.md
- codex-setup/MIGRATION_REPORT.md
- codex-setup/home/
- codex-setup/scripts/setup-codex.ps1
- codex-setup/scripts/verify-codex-home.mjs

The snapshot was generated from the user's live ~/.codex setup. It includes:
- 115 skill directories.
- 94 agent files.
- 16 hook scripts, including portable ding.sh for the Stop hook.
- GSD runtime files.
- OpenAI curated plugin cache for Notion, Supabase, and Superpowers.
- A referenced bundled marketplace under home/.tmp/bundled-marketplaces/openai-bundled.

Native notification hooks and notification config are intentionally absent:
- no notify.sh
- no PermissionRequest notification hook
- no native notify command
</context>

<constraints>
- Use local files only. Do not fetch, pull, clone, or download this repo again.
- Do not modify windows-claude-code/.
- Do not modify codex-setup/.
- Do not commit or push.
- Do not invent secret values.
- Ask the user for TAVILY_API_KEY only if they want Tavily MCP active immediately. The installed config references only TAVILY_API_KEY among active MCP env vars.
- Treat missing prerequisites as blockers.
- Before any destructive action outside the installer backup behavior, ask the user.
</constraints>

<preflight>
Run these checks before installing. Stop and report if any required check fails.

1. Confirm required files:
   ```powershell
   Test-Path .\README.md
   Test-Path .\codex-setup\BOOTSTRAP.md
   Test-Path .\codex-setup\MIGRATION_REPORT.md
   Test-Path .\codex-setup\home\AGENTS.md
   Test-Path .\codex-setup\home\config.toml
   Test-Path .\codex-setup\home\hooks.json
   Test-Path .\codex-setup\scripts\setup-codex.ps1
   Test-Path .\codex-setup\scripts\verify-codex-home.mjs
   ```
   Expected: all return True.

2. Confirm PowerShell:
   ```powershell
   $PSVersionTable.PSVersion
   ```
   Expected: PowerShell 5.1 or newer.

3. Confirm prerequisites:
   ```powershell
   codex --version
   node --version
   npm --version
   bash --version
   ```
   Expected: all commands exist. If `bash` is missing, tell the user to install Git for Windows with `winget install Git.Git`, restart PowerShell, and rerun this prompt.

4. Confirm the source snapshot validates before install:
   ```powershell
   node .\codex-setup\scripts\verify-codex-home.mjs .\codex-setup\home
   ```
   Expected: `Verified Codex home snapshot`.

5. Check whether an existing Codex home exists:
   ```powershell
   Test-Path "$env:USERPROFILE\.codex"
   ```
   If True, tell the user the installer will move it to `$env:USERPROFILE\.codex.bak.<timestamp>` before copying the new setup.
</preflight>

<install>
1. Allow this PowerShell process to run the installer:
   ```powershell
   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
   ```

2. Dry run first:
   ```powershell
   .\codex-setup\scripts\setup-codex.ps1 -DryRun
   ```
   Expected output includes:
   - `Source:`
   - `Target:`
   - `=== DRY RUN ===`
   - `No changes made.`
   If source file count is suspiciously low, below 5000, stop and report.

3. Run the real install:
   ```powershell
   .\codex-setup\scripts\setup-codex.ps1
   ```
   Expected output includes:
   - backup message if `$env:USERPROFILE\.codex` already existed
   - `Copied N files.`
   - `File counts match.`
   If file counts mismatch, stop and report the mismatch.
</install>

<verify_immediate>
Run these checks in the current shell after install.

1. Validate installed snapshot:
   ```powershell
   node .\codex-setup\scripts\verify-codex-home.mjs "$env:USERPROFILE\.codex"
   ```
   Expected: `Verified Codex home snapshot`.

2. Confirm key file counts:
   ```powershell
   (Get-ChildItem "$env:USERPROFILE\.codex\skills" -Directory).Count
   (Get-ChildItem "$env:USERPROFILE\.codex\agents" -File).Count
   (Get-ChildItem "$env:USERPROFILE\.codex\hooks" -File).Count
   ```
   Expected:
   ```text
   115
   94
   16
   ```

3. Confirm native notification hooks are absent and Stop ding is present:
   ```powershell
   Test-Path "$env:USERPROFILE\.codex\hooks\notify.sh"
   Test-Path "$env:USERPROFILE\.codex\hooks\ding.sh"
   Select-String -Path "$env:USERPROFILE\.codex\config.toml","$env:USERPROFILE\.codex\hooks.json" -Pattern "notify\.sh|PermissionRequest|notification_method|notification_condition" -Quiet
   ```
   Expected:
   ```text
   False
   True
   False
   ```

4. Confirm path materialization:
   ```powershell
   Select-String -Path "$env:USERPROFILE\.codex\config.toml" -Pattern "__CODEX_HOME__" -Quiet
   Select-String -Path "$env:USERPROFILE\.codex\config.toml" -Pattern "$($env:USERPROFILE.Replace('\','/'))/.codex" -Quiet
   ```
   Expected:
   ```text
   False
   True
   ```

5. Confirm no login secrets were bundled by file:
   ```powershell
   Test-Path "$env:USERPROFILE\.codex\auth.json"
   Test-Path "$env:USERPROFILE\.codex\.env"
   ```
   Expected:
   ```text
   False
   False
   ```
</verify_immediate>

<optional_tavily_env>
Ask the user: "Do you want to set TAVILY_API_KEY now for the Tavily MCP server?"

If yes:
1. Ask them to paste the key.
2. Set it as a user environment variable:
   ```powershell
   $TavilyApiKey = Read-Host "Enter TAVILY_API_KEY"
   [Environment]::SetEnvironmentVariable("TAVILY_API_KEY", $TavilyApiKey, "User")
   $env:TAVILY_API_KEY = $TavilyApiKey
   ```

If no:
Tell them Tavily MCP will be configured but not usable until `TAVILY_API_KEY` is set.
</optional_tavily_env>

<post_restart_verification>
Tell the user these checks require a fresh Codex session because the running session does not reload installed config.

After exiting and relaunching Codex, run:

1. Skills check:
   ```text
   /skills
   ```
   Expected: the installed skills are available, including GSD, gstack, n8n, Notion, Supabase, and Superpowers skills.

2. MCP check:
   ```text
   /mcp
   ```
   Expected: `tavily` is listed. It requires `TAVILY_API_KEY` to work.

3. Hook check:
   Ask Codex to run a benign shell command, then check recent command logs or hook output. Native notification hooks are intentionally absent, but the Stop ding hook is installed.
</post_restart_verification>

<final_report>
Print a concise final report with:
- PowerShell version.
- Whether an existing `.codex` was backed up.
- Installer copied file count.
- Immediate verification PASS or FAIL for each check.
- Whether TAVILY_API_KEY was set or skipped.
- Exact next action: exit this Codex session, relaunch Codex, run `/skills`, `/mcp`, and a hook check.

End with one line:
- `ready` if all immediate checks passed.
- `blocked: <reason>` if any check failed.
</final_report>
```
