# INSTALL_PROMPT: paste this into Codex CLI on the target machine

## How to use

1. On the target machine, install Codex CLI per the official instructions. Verify with `codex --version` from any shell.
2. Get this repo onto the machine. If you cloned it earlier, just `cd` into it. If not, copy the directory across (USB stick, scp, syncthing, whatever): the prompt reads from the local working tree, no GitHub access required.
3. Open a terminal in the repo root (the directory that contains `README.md`, `windows-claude-code/`, `codex-from-claude/`).
4. Launch Codex from that directory:
   ```
   codex
   ```
5. Paste **everything inside the code block below** as your first message.
6. Have your `SECRETS.md` content ready in your clipboard. Codex will pause and ask for it. The original lives at `windows-claude-code/SECRETS.md` (gitignored, transferred privately) or in your password manager. The prompt expects three values: `TAVILY_API_KEY`, `N8N_HOSTINGER_API_KEY`, `N8N_CITYFLEET_API_KEY`.
7. The prompt is end-to-end. It pauses only when it needs you (secrets, ambiguous fork in the road, an explicit confirmation before a destructive step).
8. After the prompt finishes its `<verify>` checks, it will tell you to exit and relaunch Codex. Do that, then run the post-restart checks the prompt surfaced.

---

## The prompt

```
<goal>
You are setting up Codex CLI on this machine using the repo in the current working directory. The repo has two folders: windows-claude-code/ (the original Claude Code config, do not modify) and codex-from-claude/ (a Codex-ready configuration with install scripts and audit reports). Execute the install end to end. End state: ~/.codex/ contains the migrated setup, secrets are wired into the shell, immediate verifications pass, the user has been told what to do after restarting Codex.
</goal>

<context>
The repo at CWD contains:
- README.md
- windows-claude-code/ (preserved, do not modify)
- codex-from-claude/BOOTSTRAP.md (authoritative install reference)
- codex-from-claude/MIGRATION_REPORT.md (what was ported, what was dropped)
- codex-from-claude/AUDIT_REPORT.md (deferred items)
- codex-from-claude/PLAN.md
- codex-from-claude/home/ (target setup contents: AGENTS.md, CLAUDE.md, config.toml, hooks.json, hooks/, skills/, agents/, rules/, memory/, reference/)
- codex-from-claude/scripts/setup-codex.sh (POSIX, including WSL)
- codex-from-claude/scripts/setup-codex.ps1 (native Windows PowerShell)

Setup writes to ~/.codex/. If ~/.codex/ already exists, the script backs it up to ~/.codex.bak.<timestamp> automatically.

The Codex session running this install will not reload its own config mid-session. Skills, hooks, and MCP servers load at session start. The user must restart Codex for the new setup to be active in their working session. Plan accordingly: split verification into immediate checks (file presence, parsing) and post-restart checks (/skills, /mcp, hook fire).
</context>

<constraints>
- Local files only. Do not git fetch, git pull, git clone, or hit any remote. Use only the working tree at CWD.
- Be methodical. Read the supporting docs before acting.
- Stop only when you genuinely need the user (secrets paste, ambiguous fork, before a destructive step).
- Do not modify windows-claude-code/.
- Do not modify codex-from-claude/.
- Do not push commits. All writes go to ~/.codex/ and the user's shell rc only.
- Do not invent secret values. Where ~/.codex/.env or env.ps1 needs filling, ask the user.
- Treat command-not-found on prerequisites as a blocker. Stop and report.
- No em-dashes anywhere in your output. Use periods, commas, or colons.
</constraints>

<preflight>
Verify environment before doing anything. If any check fails, stop and report which.

1. Working directory:
   Confirm these paths exist relative to CWD:
       README.md
       windows-claude-code/
       codex-from-claude/BOOTSTRAP.md
       codex-from-claude/MIGRATION_REPORT.md
       codex-from-claude/AUDIT_REPORT.md
       codex-from-claude/PLAN.md
       codex-from-claude/home/AGENTS.md
       codex-from-claude/home/config.toml
       codex-from-claude/home/hooks.json
       codex-from-claude/scripts/setup-codex.sh
       codex-from-claude/scripts/setup-codex.ps1
   If any are missing, stop and tell the user which.

2. OS detection:
   - macOS or Linux: setup path is the .sh script.
   - WSL on Windows: setup path is the .sh script (treat as Linux).
   - Native Windows PowerShell: setup path is the .ps1 script.
   - Other: stop and tell the user.

3. Shell:
   - macOS or Linux: bash or zsh expected.
   - Native Windows: PowerShell 5.1 or 7.x expected. If running from cmd or Git Bash, instruct user to relaunch from PowerShell so the .ps1 can run.

4. Prerequisites (run each, capture output):
       codex --version          (Codex CLI itself)
       node --version           (need 18 or newer; 3 hooks are .js)
       jq --version             (used in BOOTSTRAP verification snippets)
   On native Windows additionally:
       bash --version           (needed for hook .sh scripts; if missing, instruct user to install Git for Windows via `winget install Git.Git`, add C:/Program Files/Git/bin to PATH, then retry)

5. Existing ~/.codex/:
   - If it exists, note file count and most recent mtime. Tell the user the script will back it up before writing. Do not delete or rewrite anything until after the dry-run preview in <install> step 2.
   - If not, note that and continue.
</preflight>

<orient>
Read the supporting docs before installing. This grounds the install in actual file content, not just this prompt.

1. Read codex-from-claude/BOOTSTRAP.md end to end. Note: prerequisites, install commands, env var list, verification commands with expected output, troubleshooting.

2. Skim codex-from-claude/AUDIT_REPORT.md. Capture the "Flagged for user decision" section (3 items). Do not act on them now. Surface them at the end.

3. Skim codex-from-claude/MIGRATION_REPORT.md table-of-contents to understand what was ported, what was dropped, what is in codex-from-claude/home/reference/ (manual review material, not auto-installed).

4. Glance at codex-from-claude/home/config.toml to confirm the three MCP servers (tavily, n8n_hostinger, n8n_cityfleet) and the env-var names they reference. Cross-check against the env-var table in BOOTSTRAP.md.
</orient>

<install>
1. Make script executable on POSIX:
       chmod +x codex-from-claude/scripts/setup-codex.sh
   (skip on Windows.)

2. Dry run first. Writes nothing.
   POSIX:
       ./codex-from-claude/scripts/setup-codex.sh --dry-run
   Windows:
       .\codex-from-claude\scripts\setup-codex.ps1 -DryRun
   Inspect the output: source file count, target tree, no changes made. If source count is suspiciously low (under 2000), stop and report.

3. Real install:
   POSIX:
       ./codex-from-claude/scripts/setup-codex.sh
   Windows:
       .\codex-from-claude\scripts\setup-codex.ps1
   Confirm the script:
   a. backed up any existing ~/.codex/ to ~/.codex.bak.<timestamp>,
   b. printed a final "Copied N files." line,
   c. reported "File counts match." If mismatch warned, capture detail and tell user before proceeding.

4. Spot-check:
       test -f ~/.codex/AGENTS.md
       test -f ~/.codex/config.toml
       test -f ~/.codex/hooks.json
       ls ~/.codex/skills/ | wc -l       (expect 69)
       ls ~/.codex/agents/*.toml | wc -l (expect 46)
       ls ~/.codex/hooks/ | wc -l        (expect 17)
   Each must match. If any fails, stop and report.
</install>

<secrets>
1. Pause and ask the user for the three values from SECRETS.md:
       TAVILY_API_KEY
       N8N_HOSTINGER_API_KEY
       N8N_CITYFLEET_API_KEY
   The user pastes them. If the user says skip a key (not using that service on this machine), still set the env file with the variable name present and an empty value.

2. Write the env file.

   POSIX (~/.codex/.env), exact form:
       # ~/.codex/.env
       # Source from .bashrc / .zshrc:  set -a; source "$HOME/.codex/.env"; set +a
       TAVILY_API_KEY=<value-from-user>
       N8N_HOSTINGER_API_KEY=<value-from-user>
       N8N_CITYFLEET_API_KEY=<value-from-user>
   Then: chmod 600 ~/.codex/.env

   Windows (~/.codex/env.ps1), exact form:
       # ~/.codex/env.ps1
       # Dot-source from $PROFILE:  . "$HOME/.codex/env.ps1"
       $env:TAVILY_API_KEY = '<value-from-user>'
       $env:N8N_HOSTINGER_API_KEY = '<value-from-user>'
       $env:N8N_CITYFLEET_API_KEY = '<value-from-user>'

3. Wire into shell rc (idempotent: append only if line is not already present, show diff before writing):
   - bash:  ~/.bashrc, append `set -a; source "$HOME/.codex/.env"; set +a`
   - zsh:   ~/.zshrc, same line
   - fish:  ~/.config/fish/config.fish, translated syntax
   - PowerShell: $PROFILE, append `. "$HOME/.codex/env.ps1"`. Create $PROFILE if it does not exist.

4. Load the env into the current shell so any verification step can reach the env values:
   POSIX:    set -a; source "$HOME/.codex/.env"; set +a
   Windows:  . "$HOME/.codex/env.ps1"
</secrets>

<verify>
Run only the verifications that work in the current Codex session. Skills, hooks, and MCP servers do not load mid-session, so checks for those are deferred to <post_restart_verification>.

1. codex --version
   Expected: a version string.

2. head -20 ~/.codex/AGENTS.md
   Expected: the Codex-targeted preamble that describes the setup map.

3. File-count sanity check (mirrors <install> step 4):
       echo "agent tomls: $(ls ~/.codex/agents/*.toml | wc -l)"
       echo "skills:      $(ls ~/.codex/skills/ | wc -l)"
       echo "hook scripts: $(ls ~/.codex/hooks/ | wc -l)"
   Expected: 46, 69, 17.

4. config.toml parses cleanly:
   POSIX:   python3 -c "import tomllib, os; tomllib.loads(open(os.path.expanduser('~/.codex/config.toml')).read())"
   Windows: python -c "import tomllib, os; tomllib.loads(open(os.path.expanduser('~/.codex/config.toml')).read())"
   Expected: no error, exits 0.

5. hooks.json parses cleanly:
   jq . ~/.codex/hooks.json > /dev/null
   Expected: no error.

If any check fails, jump to the matching Troubleshooting entry in BOOTSTRAP.md. Apply the fix. Re-verify. Do not silently move on.
</verify>

<post_restart_verification>
These checks require a fresh Codex session because skills, hooks, and MCP servers load only at session start.

Surface this block to the user as their post-install task list. Do not run these checks yourself.

1. codex /skills
   Expected: 69 entries listed.

2. codex /mcp
   Expected: tavily, n8n_hostinger, n8n_cityfleet listed. Connection state depends on whether the user filled valid secrets in <secrets>.

3. Hook fire test:
   In the fresh Codex session, run a benign Bash action like `echo test-hook`.
   Then: ls -lt ~/.codex/hooks/*.log 2>/dev/null | head -1 (POSIX), or
         Get-ChildItem ~/.codex/hooks/*.log -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1 (Windows).
   Expected: a log file with mtime within the last 60 seconds. If no log file exists yet (first hook fire), inspect the Codex session output for hook-script invocation lines instead.

If any post-restart check fails, see codex-from-claude/BOOTSTRAP.md Troubleshooting.
</post_restart_verification>

<surface>
From AUDIT_REPORT.md "Flagged for user decision," present the three items as a one-sentence-each summary with the recommended next action. Do not act on them. Just surface.

1. Slash command porting: 90 plus commands in codex-from-claude/home/reference/commands/. Pick the few you actually use, port to home/skills/<name>/SKILL.md.

2. Subagent model retiering: all 46 default to gpt-5-codex. Retier per agent based on live testing of cost vs quality, by editing ~/.codex/agents/<name>.toml.

3. Secret rotation cadence: the two n8n keys are time-limited JWTs. Rotate at the n8n instance's API key page when expired.
</surface>

<final_report>
Print a final report:
- OS and shell detected.
- Whether ~/.codex/ existed before; if so, the backup path.
- Install file count (source vs target, match or mismatch).
- Verification results from <verify>: PASS/FAIL per the 5 checks.
- The three deferred items from <surface>.

Then explicit next-action lines for the user, in this order:
1. "Exit this Codex session and relaunch Codex. Skills, hooks, and MCP servers load at startup and the running session does not see the new setup."
2. "After relaunch, run the three post-restart checks: codex /skills (expect 69), codex /mcp (expect 3 servers), and a hook fire test (echo test-hook, then check ~/.codex/hooks/*.log mtime)."
3. "If any post-restart check fails, see codex-from-claude/BOOTSTRAP.md Troubleshooting."

End the report with one line: "ready" if every <verify> check passed, or "blocked: <what>" if not.
</final_report>