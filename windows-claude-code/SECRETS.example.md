# SECRETS.md template

> The real `SECRETS.md` is **gitignored**. It's only generated locally on the source machine and transferred privately (1Password / Bitwarden / Signal / encrypted note) to the target machine. After use, delete it.

This file documents the **shape** of `SECRETS.md` — what env vars to expect — without storing any values.

## Required env vars

```env
# MCP server credentials
TAVILY_API_KEY=
N8N_HOSTINGER_API_KEY=
N8N_CITYFLEET_API_KEY=
```

## Optional env vars (set if you use the corresponding tool)

```env
BRAVE_API_KEY=
FIRECRAWL_API_KEY=
EXA_API_KEY=
GEMINI_API_KEY=
OPENAI_API_KEY=
FAL_KEY=
BROWSERBASE_API_KEY=
BROWSER_USE_API_KEY=
CONFLUENCE_BASE_URL=
CONFLUENCE_EMAIL=
CONFLUENCE_API_TOKEN=
GITHUB_TOKEN=  # or run `gh auth login` instead
```

## How values get applied

1. Place values in `%USERPROFILE%\.claude\.env` on the new machine
2. Run `bootstrap-render-templates.ps1` (created during bootstrap) to substitute them into `settings.json` and `.mcp.json`
3. Anthropic auth is handled separately — `claude` CLI prompts for login on first run
