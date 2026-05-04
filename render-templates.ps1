# =====================================================================
# Render templates: substitute env vars into settings.json and .mcp.json
# =====================================================================
# Reads values from %USERPROFILE%\.claude\.env (KEY=VALUE format)
# Replaces ${VAR} placeholders in *.template.json files
# Writes the result without _template_note property
# =====================================================================

$ErrorActionPreference = 'Stop'

$claudeHome = Join-Path $env:USERPROFILE '.claude'
$envFile    = Join-Path $claudeHome '.env'

function Read-DotEnv($path) {
  $vars = @{}
  if (-not (Test-Path $path)) { return $vars }
  Get-Content $path | ForEach-Object {
    $line = $_.Trim()
    if ($line -eq '' -or $line.StartsWith('#')) { return }
    $eq = $line.IndexOf('=')
    if ($eq -lt 0) { return }
    $k = $line.Substring(0, $eq).Trim()
    $v = $line.Substring($eq + 1).Trim().Trim('"').Trim("'")
    $vars[$k] = $v
  }
  return $vars
}

function Render-Template($templatePath, $outputPath, $vars) {
  if (-not (Test-Path $templatePath)) {
    Write-Warning "Template not found: $templatePath"
    return
  }
  $text = Get-Content $templatePath -Raw

  # Substitute every ${KEY} with vars[KEY]; leave unset vars as ""
  $text = [regex]::Replace($text, '\$\{([A-Z_][A-Z0-9_]*)\}', {
    param($m)
    $key = $m.Groups[1].Value
    if ($vars.ContainsKey($key)) { return $vars[$key] } else { return '' }
  })

  # Strip the _template_note line so the rendered file is clean
  $obj = $text | ConvertFrom-Json
  if ($obj.PSObject.Properties.Name -contains '_template_note') {
    $obj.PSObject.Properties.Remove('_template_note')
  }
  $obj | ConvertTo-Json -Depth 50 | Set-Content -Path $outputPath -Encoding UTF8
  Write-Host "  rendered -> $outputPath" -ForegroundColor Green
}

if (-not (Test-Path $envFile)) {
  Write-Error ".env not found: $envFile

Create it from SECRETS.md, then re-run."
  exit 1
}

$vars = Read-DotEnv $envFile
Write-Host "==> Loaded $($vars.Count) vars from $envFile" -ForegroundColor Cyan

Render-Template `
  -templatePath (Join-Path $claudeHome 'settings.template.json') `
  -outputPath   (Join-Path $claudeHome 'settings.json') `
  -vars $vars

Render-Template `
  -templatePath (Join-Path $claudeHome '.mcp.template.json') `
  -outputPath   (Join-Path $claudeHome '.mcp.json') `
  -vars $vars

# settings.local.template.json is just permissions, no secrets — pass through
Render-Template `
  -templatePath (Join-Path $claudeHome 'settings.local.template.json') `
  -outputPath   (Join-Path $claudeHome 'settings.local.json') `
  -vars $vars

Write-Host ""
Write-Host "==> Done. Restart Claude Code." -ForegroundColor Green
