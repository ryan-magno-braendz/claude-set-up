# =====================================================================
# Claude Code setup bootstrap — Windows native
# =====================================================================
# Idempotent. Safe to re-run. Run from an elevated PowerShell prompt.
#
# Usage:
#   1. Clone repo:   git clone https://github.com/ryan-magno-braendz/claude-set-up.git
#   2. cd claude-set-up
#   3. Run:          powershell -ExecutionPolicy Bypass -File bootstrap.ps1
#   4. Place SECRETS.md values into $env:USERPROFILE\.claude\.env
#   5. Run:          powershell -ExecutionPolicy Bypass -File render-templates.ps1
#   6. Run:          claude
# =====================================================================

$ErrorActionPreference = 'Stop'
$ProgressPreference    = 'SilentlyContinue'

function Write-Step($msg) { Write-Host "==> $msg" -ForegroundColor Cyan }
function Write-Ok($msg)   { Write-Host "  OK $msg"   -ForegroundColor Green }
function Write-Warn($msg) { Write-Host "  !! $msg"   -ForegroundColor Yellow }

# ---------------------------------------------------------------------
# 0. Check prerequisites
# ---------------------------------------------------------------------
Write-Step "Checking prerequisites"

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
  throw "winget is required. Install 'App Installer' from the Microsoft Store first."
}

# ---------------------------------------------------------------------
# 1. Install system dependencies via winget
# ---------------------------------------------------------------------
$wingetPackages = @(
  @{ Id = 'Git.Git';                 Name = 'Git for Windows (provides bash, sed, awk, grep)' },
  @{ Id = 'OpenJS.NodeJS.LTS';       Name = 'Node.js LTS' },
  @{ Id = 'Python.Python.3.12';      Name = 'Python 3.12' },
  @{ Id = 'GitHub.cli';              Name = 'GitHub CLI (gh)' },
  @{ Id = 'jqlang.jq';               Name = 'jq (JSON processor)' },
  @{ Id = 'Microsoft.PowerShell';    Name = 'PowerShell 7' }
)

foreach ($pkg in $wingetPackages) {
  Write-Step "Installing $($pkg.Name)"
  $installed = winget list --id $pkg.Id --exact 2>$null | Select-String $pkg.Id
  if ($installed) {
    Write-Ok "$($pkg.Id) already installed"
  } else {
    winget install --id $pkg.Id --exact --silent --accept-source-agreements --accept-package-agreements
    Write-Ok "$($pkg.Id) installed"
  }
}

# Refresh PATH so freshly-installed tools are visible
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" +
            [System.Environment]::GetEnvironmentVariable("Path","User")

# ---------------------------------------------------------------------
# 2. Install Claude Code CLI
# ---------------------------------------------------------------------
Write-Step "Installing Claude Code"
if (Get-Command claude -ErrorAction SilentlyContinue) {
  Write-Ok "claude already installed"
} else {
  npm install -g @anthropic-ai/claude-code
  Write-Ok "Claude Code installed"
}

# ---------------------------------------------------------------------
# 3. Copy config payload to %USERPROFILE%\.claude\
# ---------------------------------------------------------------------
$repoRoot   = Split-Path -Parent $MyInvocation.MyCommand.Path
$payloadDir = Join-Path $repoRoot 'claude'
$claudeHome = Join-Path $env:USERPROFILE '.claude'

Write-Step "Syncing config to $claudeHome"
if (-not (Test-Path $claudeHome)) {
  New-Item -ItemType Directory -Force -Path $claudeHome | Out-Null
}

# robocopy: /E recurse, /XO skip older, /NFL no file list, /NDL no dir list
robocopy $payloadDir $claudeHome /E /XO /NFL /NDL /NJH /NJS | Out-Null
Write-Ok "Config payload synced"

# ---------------------------------------------------------------------
# 4. Render templates if .env exists
# ---------------------------------------------------------------------
$envFile = Join-Path $claudeHome '.env'
if (Test-Path $envFile) {
  Write-Step "Rendering templates from .env"
  & (Join-Path $repoRoot 'render-templates.ps1')
} else {
  Write-Warn ".env not found at $envFile. Templates NOT rendered."
  Write-Warn "Populate .env with values from SECRETS.md, then run: render-templates.ps1"
}

# ---------------------------------------------------------------------
# 5. Register marketplaces and install plugins
# ---------------------------------------------------------------------
Write-Step "Registering plugin marketplaces"

$marketplacesFile = Join-Path $repoRoot 'marketplaces.lock.json'
if (Test-Path $marketplacesFile) {
  $marketplaces = Get-Content $marketplacesFile | ConvertFrom-Json
  foreach ($mp in $marketplaces.marketplaces) {
    Write-Step "  Adding $($mp.name) -> $($mp.repo)"
    try {
      & claude plugin marketplace add $mp.repo 2>&1 | Out-Null
      Write-Ok "  $($mp.name) registered"
    } catch {
      Write-Warn "  $($mp.name) registration failed: $_"
    }
  }
}

Write-Step "Installing plugins"
$pluginsFile = Join-Path $repoRoot 'plugins.lock.json'
if (Test-Path $pluginsFile) {
  $plugins = Get-Content $pluginsFile | ConvertFrom-Json
  foreach ($plugin in $plugins.plugins) {
    Write-Step "  Installing $($plugin.id)"
    try {
      & claude plugin install $plugin.id 2>&1 | Out-Null
      Write-Ok "  $($plugin.id) installed"
    } catch {
      Write-Warn "  $($plugin.id) install failed: $_  (run manually)"
    }
  }
}

# ---------------------------------------------------------------------
# 6. Final notes
# ---------------------------------------------------------------------
Write-Host ""
Write-Host "================================================================" -ForegroundColor Green
Write-Host "  Claude Code setup complete." -ForegroundColor Green
Write-Host "================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. If you haven't yet:  put SECRETS.md values into $envFile"
Write-Host "                          then run: .\render-templates.ps1"
Write-Host "  2. Authenticate GitHub: gh auth login"
Write-Host "  3. First run:           claude    (will prompt Anthropic login)"
Write-Host ""
Write-Host "Read SETUP.md for Windows-native caveats (tmux, ao, gsd parallel)."
Write-Host ""
