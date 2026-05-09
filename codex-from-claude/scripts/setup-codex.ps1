#requires -Version 5.1
<#
.SYNOPSIS
    Idempotent installer for the Codex CLI configuration into %USERPROFILE%\.codex\.
.DESCRIPTION
    Copies ..\home\ into ~/.codex/. Backs up any existing ~/.codex to
    ~/.codex.bak.<timestamp> before writing. Supports -DryRun.
.PARAMETER DryRun
    Prints the file list and target tree without writing.
#>
[CmdletBinding()]
param(
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$Src = Join-Path $ScriptDir '..\home'
$Src = (Resolve-Path $Src).Path
$Dst = Join-Path $env:USERPROFILE '.codex'

if (-not (Test-Path $Src)) {
    Write-Error "Source directory not found: $Src"
    exit 1
}

$SrcFileCount = (Get-ChildItem -Path $Src -Recurse -File).Count
Write-Host "Source: $Src ($SrcFileCount files)"
Write-Host "Target: $Dst"
Write-Host ""

if ($DryRun) {
    Write-Host "=== DRY RUN ==="
    Write-Host ""
    Write-Host "Files that would be copied:"
    Get-ChildItem -Path $Src -Recurse -File | ForEach-Object {
        $rel = $_.FullName.Substring($Src.Length).TrimStart('\','/').Replace('\','/')
        Write-Host "  $rel"
    } | Sort-Object
    Write-Host ""
    Write-Host "Resulting tree at ${Dst}:"
    Get-ChildItem -Path $Src -Recurse -Directory | ForEach-Object {
        $rel = $_.FullName.Substring($Src.Length).TrimStart('\','/').Replace('\','/')
        Write-Host "  $Dst/$rel"
    } | Sort-Object
    Write-Host ""
    Write-Host "No changes made."
    exit 0
}

# Backup existing
if (Test-Path $Dst) {
    $ts = Get-Date -Format 'yyyyMMdd-HHmmss'
    $backup = "$Dst.bak.$ts"
    Write-Host "Backing up existing $Dst to $backup"
    Move-Item -Path $Dst -Destination $backup
}

# Create target and copy
New-Item -Path $Dst -ItemType Directory -Force | Out-Null
Copy-Item -Path (Join-Path $Src '*') -Destination $Dst -Recurse -Force

$DstFileCount = (Get-ChildItem -Path $Dst -Recurse -File).Count
Write-Host ""
Write-Host "Copied $DstFileCount files."
if ($DstFileCount -ne $SrcFileCount) {
    Write-Warning "File count mismatch (source=$SrcFileCount, target=$DstFileCount). Inspect $Dst manually."
} else {
    Write-Host "File counts match."
}

Write-Host ""
Write-Host "Install complete."
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Set environment variables: TAVILY_API_KEY, N8N_HOSTINGER_API_KEY, N8N_CITYFLEET_API_KEY."
Write-Host "     Add to your PowerShell profile or a .env loader."
Write-Host "  2. Ensure Git Bash is on PATH so hook .sh scripts can run."
Write-Host "     (winget install Git.Git, then add C:\Program Files\Git\bin to PATH.)"
Write-Host "  3. Run: codex --version"
Write-Host "  4. Verify skills: codex /skills"
Write-Host "  5. Verify hooks: edit a file under a Codex session, watch for the lint hook output."
Write-Host ""
Write-Host "Troubleshooting and full guide: BOOTSTRAP.md (sibling of this script)."
