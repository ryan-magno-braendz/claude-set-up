# Claude Code and Codex setup

Two top-level folders. One preserves Ryan's working Windows Claude Code (CC) setup verbatim. The other is a self-contained Codex CLI setup package.

## Folders

### `windows-claude-code/`

Byte-identical snapshot of the original CC config, captured on macOS and tested on Windows. Contains the bootstrap script, the rendered `claude/` payload mirror, the secrets template, and the install docs (`SETUP.md`, `INSTALL_PROMPT.md`).

Use this folder when:
- you want a fresh Claude Code install on a new Windows machine.
- you want to read the canonical source for any rule, agent, skill, or hook.

The CC install path is documented in `windows-claude-code/SETUP.md`.

### `codex-setup/`

Self-contained Codex CLI configuration generated from the live `~/.codex/` setup. Includes a POSIX installer, a PowerShell installer, the full `~/.codex/` payload under `home/`, plus `BOOTSTRAP.md`, `INSTALL_PROMPT.md`, and `MIGRATION_REPORT.md`.

Use this folder when:
- you want Codex CLI on a new machine without re-installing Claude Code.
- you want to walk away from CC and have Codex running on day one with equivalent skills, agents, hooks, MCP servers, and global rules.

The Codex install path is documented in `codex-setup/BOOTSTRAP.md`.

## On a new device

Pick one folder. The two paths are independent.

For Claude Code:
```bash
git clone <this-repo>
cd <this-repo>/windows-claude-code
# follow SETUP.md
```

For Codex:
```bash
git clone <this-repo>
cd <this-repo>/codex-setup
# Windows
.\scripts\setup-codex.ps1
# macOS or Linux
./scripts/setup-codex.sh
```

Both installers back up any existing config before writing and support a dry-run flag.

## What was dropped during the Codex migration

Short list. Full table with reasons in `codex-setup/MIGRATION_REPORT.md`:
- The permission-request notification hook and native notification config.
- `notify.sh`; `ding.sh` is retained for the Stop hook.
- Login state, API keys, session history, logs, SQLite runtime DBs, caches, and machine-local trust state.
- Mac-only project trust entries and hook trust hashes.

## Repository layout

```
.
├── README.md                 (this file)
├── windows-claude-code/      (original CC config, byte-identical)
└── codex-setup/              (Codex CLI setup package)
    ├── BOOTSTRAP.md          (read this on a new machine for Codex install)
    ├── INSTALL_PROMPT.md     (paste-into-Codex prompt for hands-off install)
    ├── MIGRATION_REPORT.md   (per-artifact disposition, kept/modified/dropped)
    ├── README.md             (folder overview)
    ├── home/                 (mirror of target ~/.codex/)
    └── scripts/              (setup-codex.sh and setup-codex.ps1)
```
