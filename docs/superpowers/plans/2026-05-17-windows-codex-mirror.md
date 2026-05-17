# Windows Codex Mirror Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Update `codex-from-claude` so it can install the current live `~/.codex` setup onto a Windows machine as a one-to-one functional mirror, excluding notification hooks.

**Architecture:** Treat `/Users/gabrielmagno/.codex` as the source of truth and `codex-from-claude/home` as a sanitized, portable snapshot. A snapshot script copies durable setup artifacts, strips notification behavior and machine runtime state, replaces Mac-only absolute paths with `__CODEX_HOME__`, and the Windows installer materializes that placeholder as `$env:USERPROFILE\.codex`.

**Tech Stack:** Bash, PowerShell 5.1+, Node.js for JSON/TOML sanitization checks, Git Bash on Windows for existing shell hook compatibility, Codex CLI config files.

---

## Current Findings

- Live setup has `115` skill directories under `/Users/gabrielmagno/.codex/skills`.
- Current repo snapshot has `48` skill directories under `codex-from-claude/home/skills`.
- Live setup has `94` files under `/Users/gabrielmagno/.codex/agents`.
- Current repo snapshot has `46` files under `codex-from-claude/home/agents`.
- Live setup includes plugin config and plugin cache for Notion, Supabase, and Superpowers.
- Live setup includes a first-class `get-shit-done/` tree that the old README says was not migrated.
- Live config contains notification behavior:
  - `notify = ["bash", "/Users/gabrielmagno/.codex/hooks/notify.sh"]`
  - `[tui] notifications`, `notification_condition`, and `notification_method`
  - `PermissionRequest` hook calling `notify.sh`
  - `Stop` hook calling `ding.sh`
- Live config contains machine runtime sections that must not be copied as-is:
  - `[hooks.state]` trust hashes keyed by Mac paths
  - `[projects."/Users/..."]` trust entries for Mac-only project paths
  - runtime DB/log/history/cache files

## Scope Decisions

- "One-to-one copy" means all durable Codex behavior and assets: `AGENTS.md`, `CLAUDE.md`, `config.toml`, `hooks.json` minus notification hooks, non-notification hook scripts, agents, skills, rules, memory, reference, plugin cache, vendor imports, GSD files, and version metadata.
- Do not commit secrets or machine-local runtime files. `auth.json`, `.env`, history, logs, SQLite state, sessions, shell snapshots, caches, and installation IDs are not setup artifacts.
- Windows setup should require the user to run `codex login` and set API keys as environment variables, rather than placing private credentials into the repo.
- Existing non-notification hooks stay enabled and run through Git Bash on Windows.
- The Windows installer should rewrite `__CODEX_HOME__` to a forward-slash Windows path like `C:/Users/<name>/.codex`, which is valid in TOML and avoids escaping backslashes.

## File Structure

- Create `codex-from-claude/scripts/snapshot-codex.sh`
  - Refreshes `codex-from-claude/home` from live `/Users/gabrielmagno/.codex`.
  - Copies only durable setup artifacts.
  - Calls the sanitizer and verifier.

- Create `codex-from-claude/scripts/sanitize-codex-home.mjs`
  - Removes notification hooks from `hooks.json`.
  - Removes notification settings, Mac project trust blocks, and hook trust state from `config.toml`.
  - Replaces `/Users/gabrielmagno/.codex` with `__CODEX_HOME__`.

- Create `codex-from-claude/scripts/verify-codex-home.mjs`
  - Fails if the snapshot contains secrets, runtime files, notification hook references, or unresolved Mac `.codex` paths.
  - Checks required directories exist.

- Modify `codex-from-claude/scripts/setup-codex.ps1`
  - Materializes `__CODEX_HOME__` after copying.
  - Excludes no files at install time because the snapshot is already sanitized.
  - Adds Windows-specific post-install checks.

- Modify `codex-from-claude/scripts/setup-codex.sh`
  - Materializes `__CODEX_HOME__` after copying.
  - Keeps POSIX install behavior aligned with Windows.

- Modify `.gitignore`
  - Add local private overlay exclusions for accidental auth/env transfers.

- Modify `codex-from-claude/README.md`
  - Reflect the current snapshot contents and Windows install flow.

- Modify `codex-from-claude/BOOTSTRAP.md`
  - Add exact Windows prerequisites and verification commands.

- Modify `codex-from-claude/MIGRATION_REPORT.md`
  - Record the updated migration disposition: plugins and GSD are now included, notification hooks are excluded.

---

### Task 1: Add Snapshot Sanitizer

**Files:**
- Create: `codex-from-claude/scripts/sanitize-codex-home.mjs`
- Test: `codex-from-claude/scripts/verify-codex-home.mjs` is added in Task 2

- [ ] **Step 1: Create the sanitizer**

Create `codex-from-claude/scripts/sanitize-codex-home.mjs` with this content:

```javascript
#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';

const homeDir = process.argv[2];

if (!homeDir) {
  console.error('Usage: node scripts/sanitize-codex-home.mjs <snapshot-home-dir>');
  process.exit(2);
}

const resolvedHome = path.resolve(homeDir);
const configPath = path.join(resolvedHome, 'config.toml');
const hooksPath = path.join(resolvedHome, 'hooks.json');
const sourceCodexHome = '/Users/gabrielmagno/.codex';
const placeholder = '__CODEX_HOME__';

function readFile(filePath) {
  if (!fs.existsSync(filePath)) {
    throw new Error(`Required file missing: ${filePath}`);
  }
  return fs.readFileSync(filePath, 'utf8');
}

function writeFile(filePath, content) {
  fs.writeFileSync(filePath, content.endsWith('\n') ? content : `${content}\n`);
}

function sanitizeConfigToml() {
  const input = readFile(configPath).split(/\r?\n/);
  const output = [];
  let skippingSection = false;

  for (const line of input) {
    const section = line.match(/^\[([^\]]+)\]\s*$/);
    if (section) {
      const sectionName = section[1];
      skippingSection =
        sectionName === 'hooks.state' ||
        sectionName.startsWith('hooks.state.') ||
        sectionName.startsWith('projects."/Users/');
    }

    if (skippingSection) {
      continue;
    }

    if (/^notify\s*=/.test(line)) {
      continue;
    }

    if (/^\s*notifications\s*=/.test(line)) {
      continue;
    }

    if (/^\s*notification_condition\s*=/.test(line)) {
      continue;
    }

    if (/^\s*notification_method\s*=/.test(line)) {
      continue;
    }

    output.push(line.replaceAll(sourceCodexHome, placeholder));
  }

  writeFile(configPath, output.join('\n').replace(/\n{3,}/g, '\n\n'));
}

function commandMentionsNotification(command) {
  return /\bnotify\.sh\b|\bding\.sh\b/.test(command);
}

function sanitizeHooksJson() {
  const parsed = JSON.parse(readFile(hooksPath));
  const hooks = parsed.hooks ?? {};

  delete hooks.PermissionRequest;
  delete hooks.Notification;

  for (const [eventName, groups] of Object.entries(hooks)) {
    if (!Array.isArray(groups)) {
      continue;
    }

    hooks[eventName] = groups
      .map((group) => {
        const nextGroup = { ...group };
        nextGroup.hooks = (group.hooks ?? []).filter((hook) => {
          return !commandMentionsNotification(String(hook.command ?? ''));
        });
        return nextGroup;
      })
      .filter((group) => Array.isArray(group.hooks) && group.hooks.length > 0);
  }

  parsed.hooks = hooks;
  parsed._note = 'Generated from live ~/.codex. Notification hooks were intentionally removed for the Windows mirror.';

  writeFile(hooksPath, JSON.stringify(parsed, null, 2));
}

sanitizeConfigToml();
sanitizeHooksJson();
```

- [ ] **Step 2: Make the sanitizer executable**

Run:

```bash
chmod +x codex-from-claude/scripts/sanitize-codex-home.mjs
```

Expected: command exits `0`.

- [ ] **Step 3: Syntax-check the sanitizer**

Run:

```bash
node --check codex-from-claude/scripts/sanitize-codex-home.mjs
```

Expected: no output and exit `0`.

- [ ] **Step 4: Commit**

```bash
git add codex-from-claude/scripts/sanitize-codex-home.mjs
git commit -m "feat: add codex snapshot sanitizer"
```

---

### Task 2: Add Snapshot Verifier

**Files:**
- Create: `codex-from-claude/scripts/verify-codex-home.mjs`

- [ ] **Step 1: Create the verifier**

Create `codex-from-claude/scripts/verify-codex-home.mjs` with this content:

```javascript
#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';

const homeDir = process.argv[2];

if (!homeDir) {
  console.error('Usage: node scripts/verify-codex-home.mjs <snapshot-home-dir>');
  process.exit(2);
}

const root = path.resolve(homeDir);
const requiredPaths = [
  'AGENTS.md',
  'config.toml',
  'hooks.json',
  'agents',
  'hooks',
  'skills',
  'rules',
  'memory',
  'reference',
  'get-shit-done',
  'plugins/cache',
];

const forbiddenRelativePaths = [
  '.env',
  'auth.json',
  'history.jsonl',
  'installation_id',
  'log',
  'logs',
  'logs_2.sqlite',
  'logs_2.sqlite-shm',
  'logs_2.sqlite-wal',
  'sessions',
  'shell_snapshots',
  'sqlite',
  'state_5.sqlite',
  'state_5.sqlite-shm',
  'state_5.sqlite-wal',
  'tmp',
  '.tmp',
];

const forbiddenText = [
  '/Users/gabrielmagno/.codex',
  'notify.sh',
  'ding.sh',
  'PermissionRequest',
  'notification_method',
  'notification_condition',
];

function exists(relativePath) {
  return fs.existsSync(path.join(root, relativePath));
}

function walk(dir) {
  const entries = fs.readdirSync(dir, { withFileTypes: true });
  const files = [];

  for (const entry of entries) {
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      files.push(...walk(fullPath));
    } else if (entry.isFile()) {
      files.push(fullPath);
    }
  }

  return files;
}

const failures = [];

for (const relativePath of requiredPaths) {
  if (!exists(relativePath)) {
    failures.push(`Missing required path: ${relativePath}`);
  }
}

for (const relativePath of forbiddenRelativePaths) {
  if (exists(relativePath)) {
    failures.push(`Forbidden runtime or secret path present: ${relativePath}`);
  }
}

const textFiles = walk(root).filter((filePath) => {
  const relativePath = path.relative(root, filePath).replaceAll(path.sep, '/');
  return /\.(json|toml|md|sh|ps1|mjs|js|txt|rules)$/.test(relativePath) || relativePath === 'AGENTS.md';
});

for (const filePath of textFiles) {
  const relativePath = path.relative(root, filePath).replaceAll(path.sep, '/');
  const content = fs.readFileSync(filePath, 'utf8');

  for (const text of forbiddenText) {
    if (content.includes(text)) {
      failures.push(`Forbidden text "${text}" found in ${relativePath}`);
    }
  }
}

if (failures.length > 0) {
  console.error('Codex home snapshot verification failed:');
  for (const failure of failures) {
    console.error(`- ${failure}`);
  }
  process.exit(1);
}

console.log(`Verified Codex home snapshot: ${root}`);
```

- [ ] **Step 2: Make the verifier executable**

Run:

```bash
chmod +x codex-from-claude/scripts/verify-codex-home.mjs
```

Expected: command exits `0`.

- [ ] **Step 3: Syntax-check the verifier**

Run:

```bash
node --check codex-from-claude/scripts/verify-codex-home.mjs
```

Expected: no output and exit `0`.

- [ ] **Step 4: Commit**

```bash
git add codex-from-claude/scripts/verify-codex-home.mjs
git commit -m "test: add codex snapshot verifier"
```

---

### Task 3: Add Live Snapshot Script

**Files:**
- Create: `codex-from-claude/scripts/snapshot-codex.sh`
- Modify: `codex-from-claude/home/`
- Test: `codex-from-claude/scripts/verify-codex-home.mjs`

- [ ] **Step 1: Create the snapshot script**

Create `codex-from-claude/scripts/snapshot-codex.sh` with this content:

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SRC="${CODEX_SOURCE_HOME:-$HOME/.codex}"
DST="$PROJECT_DIR/home"

if [ ! -d "$SRC" ]; then
  echo "ERROR: source Codex home not found: $SRC" >&2
  exit 1
fi

if [ ! -f "$SRC/config.toml" ]; then
  echo "ERROR: source config.toml not found: $SRC/config.toml" >&2
  exit 1
fi

TMP="$(mktemp -d)"
cleanup() {
  rm -rf "$TMP"
}
trap cleanup EXIT

mkdir -p "$TMP/home"

copy_path() {
  local rel="$1"
  if [ -e "$SRC/$rel" ]; then
    mkdir -p "$TMP/home/$(dirname "$rel")"
    rsync -a "$SRC/$rel" "$TMP/home/$rel"
  fi
}

copy_path "AGENTS.md"
copy_path "CLAUDE.md"
copy_path "config.toml"
copy_path "hooks.json"
copy_path "version.json"
copy_path "gsd-file-manifest.json"
copy_path "agents/"
copy_path "hooks/"
copy_path "skills/"
copy_path "rules/"
copy_path "memory/"
copy_path "reference/"
copy_path "get-shit-done/"
copy_path "plugins/cache/"
copy_path "vendor_imports/"

rm -f "$TMP/home/hooks/notify.sh" "$TMP/home/hooks/ding.sh"

node "$SCRIPT_DIR/sanitize-codex-home.mjs" "$TMP/home"
node "$SCRIPT_DIR/verify-codex-home.mjs" "$TMP/home"

rm -rf "$DST"
mkdir -p "$DST"
rsync -a "$TMP/home/" "$DST/"

echo "Snapshot refreshed from $SRC into $DST"
find "$DST" -maxdepth 1 -mindepth 1 -print | sort
```

- [ ] **Step 2: Make the snapshot script executable**

Run:

```bash
chmod +x codex-from-claude/scripts/snapshot-codex.sh
```

Expected: command exits `0`.

- [ ] **Step 3: Syntax-check the snapshot script**

Run:

```bash
bash -n codex-from-claude/scripts/snapshot-codex.sh
```

Expected: no output and exit `0`.

- [ ] **Step 4: Refresh the snapshot**

Run:

```bash
codex-from-claude/scripts/snapshot-codex.sh
```

Expected output includes:

```text
Verified Codex home snapshot:
Snapshot refreshed from /Users/gabrielmagno/.codex into
```

- [ ] **Step 5: Verify expected live assets landed**

Run:

```bash
find codex-from-claude/home/skills -maxdepth 1 -mindepth 1 -type d | wc -l
find codex-from-claude/home/agents -maxdepth 1 -type f | wc -l
test -d codex-from-claude/home/plugins/cache/openai-curated/superpowers
test -d codex-from-claude/home/get-shit-done
```

Expected:

```text
115
94
```

The two `test -d` commands exit `0`.

- [ ] **Step 6: Commit**

```bash
git add codex-from-claude/scripts/snapshot-codex.sh codex-from-claude/home
git commit -m "feat: refresh codex home snapshot from live setup"
```

---

### Task 4: Update Windows Installer Path Materialization

**Files:**
- Modify: `codex-from-claude/scripts/setup-codex.ps1`

- [ ] **Step 1: Add placeholder materialization after copy**

In `codex-from-claude/scripts/setup-codex.ps1`, after this existing line:

```powershell
Copy-Item -Path (Join-Path $Src '*') -Destination $Dst -Recurse -Force
```

insert:

```powershell
$CodexHomeForConfig = $Dst.Replace('\', '/')
$TextExtensions = @('*.toml', '*.json', '*.md', '*.sh', '*.js', '*.mjs', '*.ps1')
foreach ($Pattern in $TextExtensions) {
    Get-ChildItem -Path $Dst -Recurse -File -Filter $Pattern | ForEach-Object {
        $Content = Get-Content -Path $_.FullName -Raw
        if ($Content.Contains('__CODEX_HOME__')) {
            $Content = $Content.Replace('__CODEX_HOME__', $CodexHomeForConfig)
            Set-Content -Path $_.FullName -Value $Content -NoNewline
        }
    }
}
```

- [ ] **Step 2: Replace notification-oriented next steps**

In the same file, replace:

```powershell
Write-Host "  5. Verify hooks: edit a file under a Codex session, watch for the lint hook output."
```

with:

```powershell
Write-Host "  5. Verify hooks: edit a file under a Codex session, watch for non-notification hook output."
Write-Host "     Notification hooks are intentionally excluded from this Windows mirror."
```

- [ ] **Step 3: Add post-install warning for Git Bash**

After the existing Git Bash next step text, insert:

```powershell
if (-not (Get-Command bash -ErrorAction SilentlyContinue)) {
    Write-Warning "bash was not found on PATH. Install Git for Windows before relying on shell hooks."
}
```

- [ ] **Step 4: Syntax-check the PowerShell script**

Run:

```bash
pwsh -NoProfile -Command '$null = [System.Management.Automation.PSParser]::Tokenize((Get-Content -Raw "codex-from-claude/scripts/setup-codex.ps1"), [ref]$null); "OK"'
```

Expected:

```text
OK
```

If `pwsh` is unavailable on macOS, run this check on the Windows target before installing:

```powershell
$null = [System.Management.Automation.PSParser]::Tokenize((Get-Content -Raw ".\scripts\setup-codex.ps1"), [ref]$null); "OK"
```

- [ ] **Step 5: Commit**

```bash
git add codex-from-claude/scripts/setup-codex.ps1
git commit -m "feat: materialize codex home paths on windows install"
```

---

### Task 5: Update POSIX Installer Path Materialization

**Files:**
- Modify: `codex-from-claude/scripts/setup-codex.sh`

- [ ] **Step 1: Materialize placeholder after POSIX copy**

In `codex-from-claude/scripts/setup-codex.sh`, after:

```bash
( cd "$SRC" && tar c . ) | ( cd "$DST" && tar x )
```

insert:

```bash
CODEX_HOME_FOR_CONFIG="$DST"
find "$DST" -type f \( -name '*.toml' -o -name '*.json' -o -name '*.md' -o -name '*.sh' -o -name '*.js' -o -name '*.mjs' \) -print0 |
  xargs -0 perl -0pi -e "s#__CODEX_HOME__#${CODEX_HOME_FOR_CONFIG}#g"
```

- [ ] **Step 2: Replace notification-oriented next step**

Replace:

```bash
  4. Verify hooks: edit a file under a Codex session, watch for the lint hook output.
```

with:

```bash
  4. Verify hooks: edit a file under a Codex session, watch for non-notification hook output.
     Notification hooks are intentionally excluded from this mirror.
```

- [ ] **Step 3: Syntax-check the POSIX installer**

Run:

```bash
bash -n codex-from-claude/scripts/setup-codex.sh
```

Expected: no output and exit `0`.

- [ ] **Step 4: Commit**

```bash
git add codex-from-claude/scripts/setup-codex.sh
git commit -m "feat: materialize codex home paths on posix install"
```

---

### Task 6: Add Private Overlay Exclusions

**Files:**
- Modify: `.gitignore`

- [ ] **Step 1: Add private transfer exclusions**

Append to `.gitignore`:

```gitignore

# Local-only Codex credential transfer overlays. Do not commit.
codex-from-claude/private-home/
codex-from-claude/**/*.private.*
codex-from-claude/**/auth.json
codex-from-claude/**/.env
```

- [ ] **Step 2: Verify ignore behavior**

Run:

```bash
mkdir -p codex-from-claude/private-home
touch codex-from-claude/private-home/auth.json
git check-ignore codex-from-claude/private-home/auth.json
rm codex-from-claude/private-home/auth.json
rmdir codex-from-claude/private-home
```

Expected:

```text
codex-from-claude/private-home/auth.json
```

- [ ] **Step 3: Commit**

```bash
git add .gitignore
git commit -m "chore: ignore private codex transfer overlays"
```

---

### Task 7: Update Documentation

**Files:**
- Modify: `codex-from-claude/README.md`
- Modify: `codex-from-claude/BOOTSTRAP.md`
- Modify: `codex-from-claude/MIGRATION_REPORT.md`

- [ ] **Step 1: Update README snapshot description**

In `codex-from-claude/README.md`, replace the `What is in home` table with:

```markdown
## What is in `home/`

| Path | Source equivalent |
|---|---|
| `home/AGENTS.md` | Codex-targeted global instructions from the live setup. |
| `home/CLAUDE.md` | Original Claude fallback project doc. |
| `home/config.toml` | Current Codex settings, MCP servers, plugins, GSD agent registrations, with machine paths templated as `__CODEX_HOME__`. |
| `home/hooks.json` | Current non-notification hooks. Notification and permission-request notification hooks are intentionally excluded. |
| `home/hooks/` | Non-notification hook scripts used by the live setup. |
| `home/skills/` | Current live skill directories, including GSD, gstack, n8n, and plugin-provided skills. |
| `home/agents/` | Current live subagent TOML and markdown definitions. |
| `home/rules/` | Layered coding rules. |
| `home/memory/` | Reference memory files. |
| `home/reference/` | Read-only reference archive. |
| `home/get-shit-done/` | Current local GSD runtime package and templates needed by GSD skills. |
| `home/plugins/cache/` | Cached OpenAI-curated Notion, Supabase, and Superpowers plugin skills. |
| `home/vendor_imports/` | Current vendor import metadata. |
```

- [ ] **Step 2: Add Windows install command block**

In `codex-from-claude/README.md`, ensure the Windows install section says:

````markdown
Windows:
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\scripts\setup-codex.ps1 -DryRun
.\scripts\setup-codex.ps1
codex login
codex --version
```
````

- [ ] **Step 3: Add Windows prerequisites to BOOTSTRAP**

Add this section near the top of `codex-from-claude/BOOTSTRAP.md`:

````markdown
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
````

- [ ] **Step 4: Update migration report disposition**

Add this section to `codex-from-claude/MIGRATION_REPORT.md`:

```markdown
## 2026-05-17 Windows Mirror Refresh

Included from live `~/.codex`:

- Current `skills/`, including `.system`, GSD skills, gstack skills, n8n skills, and plugin-provided skills.
- Current `agents/`, including GSD markdown and TOML agent definitions.
- Current `get-shit-done/` runtime package, templates, references, and SDK files.
- Current OpenAI-curated plugin cache for Notion, Supabase, and Superpowers.
- Current `memory/`, `rules/`, `reference/`, `vendor_imports/`, and version metadata.

Excluded intentionally:

- Notification hooks and native notification config.
- `auth.json`, `.env`, API keys, login state, session history, logs, SQLite runtime DBs, shell snapshots, temporary directories, and installation IDs.
- Mac-only project trust entries and hook trust hashes.
```

- [ ] **Step 5: Commit**

```bash
git add codex-from-claude/README.md codex-from-claude/BOOTSTRAP.md codex-from-claude/MIGRATION_REPORT.md
git commit -m "docs: document windows codex mirror setup"
```

---

### Task 8: End-to-End Verification

**Files:**
- Verify: `codex-from-claude/home`
- Verify: `codex-from-claude/scripts/setup-codex.ps1`
- Verify: `codex-from-claude/scripts/setup-codex.sh`

- [ ] **Step 1: Run snapshot verifier**

Run:

```bash
node codex-from-claude/scripts/verify-codex-home.mjs codex-from-claude/home
```

Expected:

```text
Verified Codex home snapshot:
```

- [ ] **Step 2: Confirm notification hooks are absent**

Run:

```bash
rg "notify\\.sh|ding\\.sh|PermissionRequest|notification_method|notification_condition" codex-from-claude/home
```

Expected: command exits `1` with no matches.

- [ ] **Step 3: Confirm Mac `.codex` paths are absent**

Run:

```bash
rg "/Users/gabrielmagno/\\.codex" codex-from-claude/home
```

Expected: command exits `1` with no matches.

- [ ] **Step 4: Confirm path placeholders exist before install**

Run:

```bash
rg "__CODEX_HOME__" codex-from-claude/home/config.toml
```

Expected: matches only paths that should be materialized during install, especially GSD agent `config_file` values.

- [ ] **Step 5: Dry-run Windows installer when PowerShell is available**

Run on macOS if `pwsh` is installed, otherwise run on Windows:

```bash
pwsh -NoProfile -File codex-from-claude/scripts/setup-codex.ps1 -DryRun
```

Expected output includes:

```text
=== DRY RUN ===
No changes made.
```

- [ ] **Step 6: Dry-run POSIX installer**

Run:

```bash
codex-from-claude/scripts/setup-codex.sh --dry-run
```

Expected output includes:

```text
=== DRY RUN ===
No changes made.
```

- [ ] **Step 7: Review final diff**

Run:

```bash
git status --short
git diff --stat
```

Expected: only intended files changed. Existing pre-plan user changes under `codex-from-claude/home` are expected to be replaced by the refreshed live snapshot because the live setup is the source of truth.

- [ ] **Step 8: Commit verification fixes if needed**

If verification required fixes, commit them:

```bash
git add codex-from-claude .gitignore
git commit -m "fix: complete windows codex mirror verification"
```

If no fixes were needed, do not create an empty commit.

## Self-Review

**Spec coverage:** The plan gathers the current live Codex setup, refreshes the setup snapshot, includes plugins and GSD, adds Windows materialization, excludes notification hooks, documents Windows bootstrapping, and verifies no secrets/runtime files are included.

**Placeholder scan:** The plan uses only one intentional implementation placeholder, `__CODEX_HOME__`, which is part of the installer design and is materialized by both installers. There are no `TBD`, `TODO`, or unspecified implementation steps.

**Type consistency:** Script names, command paths, and marker strings are consistent across sanitizer, verifier, snapshot script, installers, and verification commands.
