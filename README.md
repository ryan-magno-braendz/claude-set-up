# claude-set-up

A reproducible snapshot of Ryan's Claude Code configuration. Cloning this repo + running the bootstrap on a new machine reconstructs the entire `~/.claude/` directory: agents, skills, hooks, commands, rules, plugins, memory, MCP servers.

## What this is

The source of truth lives at `~/.claude/` on the primary macOS machine. Periodically, the relevant subset (config + skills + agents + hooks + memory) is mirrored into `claude/` here. Plugins are not committed (they're reinstalled by the bootstrap from `plugins.lock.json`). Secrets are not committed (they live in a separate, privately-transferred `SECRETS.md`).

## Quick start

```powershell
git clone https://github.com/ryan-magno-braendz/claude-set-up.git
cd claude-set-up
powershell -ExecutionPolicy Bypass -File bootstrap.ps1
# (receive SECRETS.md privately, populate %USERPROFILE%\.claude\.env)
powershell -ExecutionPolicy Bypass -File render-templates.ps1
claude
```

Full guide: see [`SETUP.md`](./SETUP.md).
Compatibility caveats (this is a Windows-native target with some POSIX features degraded): see the matrix at the bottom of `SETUP.md`.

## Layout

```
claude-set-up/
├── README.md                     # this file
├── SETUP.md                      # step-by-step Windows install
├── SECRETS.example.md            # shape of SECRETS.md (real one is gitignored)
├── bootstrap.ps1                 # PowerShell installer
├── render-templates.ps1          # substitutes .env into settings.json + .mcp.json
├── plugins.lock.json             # 7 plugins to reinstall, with versions
├── marketplaces.lock.json        # 8 marketplaces to register first
├── .gitignore                    # excludes runtime state, plugins/, secrets
└── claude/                       # mirrors ~/.claude/ (config payload only)
    ├── CLAUDE.md, AGENTS.md, README.md, statusline.js
    ├── settings.template.json    # rendered to settings.json
    ├── .mcp.template.json        # rendered to .mcp.json
    ├── settings.local.template.json
    ├── agents/                   # 48 agent definitions
    ├── commands/                 # 62 slash commands incl. /gsd:*
    ├── hooks/                    # 23 hook scripts (POSIX, run via Git Bash)
    ├── rules/                    # common + per-language coding rules
    ├── skills/                   # 70 custom skills
    ├── memory/                   # auto-memory (kept across devices)
    ├── ecc/, scripts/, get-shit-done/, teams/, mcp-configs/
    └── .cursor/, .codex/, .opencode/, .agents/
```

## Source machine: how to update this repo

```bash
cd ~/Documents/Projects/Claude\ Set-up/claude-set-up

# Sync ~/.claude/ into claude/, respecting .gitignore exclusions
rsync -av --delete \
  --exclude='projects/' --exclude='sessions/' --exclude='todos/' \
  --exclude='tasks/' --exclude='cache/' --exclude='paste-cache/' \
  --exclude='shell-snapshots/' --exclude='telemetry/' --exclude='logs/' \
  --exclude='file-history/' --exclude='ide/' --exclude='session-env/' \
  --exclude='debug/' --exclude='backups/' --exclude='homunculus/' \
  --exclude='plugins/' --exclude='*.bak.*' --exclude='history.jsonl' \
  --exclude='*-cache.json' \
  --exclude='settings.json' --exclude='.mcp.json' --exclude='settings.local.json' \
  ~/.claude/ claude/

git add -A
git commit -m "sync: $(date +%Y-%m-%d)"
git push
```

Note: live `settings.json` and `.mcp.json` are excluded from the rsync — only the `*.template.json` versions live in the repo, since those have secrets stripped.

## Security

- `SECRETS.md`, `.env`, `claude/settings.json`, `claude/.mcp.json` are all in `.gitignore`. Even if you `git add -A`, they don't go in.
- Even with a private repo, leaks happen (forks, accidental publish, repo-visibility flips). Treat the templated configs as the only safe-to-commit form of MCP config.
- After transferring `SECRETS.md` privately, delete the transfer copy.
- Both n8n JWTs in `SECRETS.md` are time-limited; rotate them periodically.

## License

Personal config — no license. Don't copy specific values without permission.
