Write-Host "=== Nuke barnhk, then reinstall ===" -ForegroundColor Cyan

# 1. Uninstall via CLI
Write-Host "[1/4] Uninstalling..." -ForegroundColor Yellow
claude plugin uninstall barnhk@cckit --scope user 2>&1 | Out-Null
Write-Host "  Done" -ForegroundColor Gray

# 2. Nuke cache
Write-Host "[2/4] Removing cache..." -ForegroundColor Yellow
$cachePath = "$env:USERPROFILE\.claude\plugins\cache\cckit\barnhk"
if (Test-Path $cachePath) {
    Remove-Item -Recurse -Force $cachePath -ErrorAction SilentlyContinue
    Write-Host "  Removed: $cachePath" -ForegroundColor Gray
} else {
    Write-Host "  Not found (already clean)" -ForegroundColor Gray
}

# 3. Clean installed_plugins.json
Write-Host "[3/4] Cleaning installed_plugins.json..." -ForegroundColor Yellow
$installedPath = "$env:USERPROFILE\.claude\plugins\installed_plugins.json"
if (Test-Path $installedPath) {
    $json = Get-Content $installedPath -Raw | ConvertFrom-Json
    if ($json.plugins.PSObject.Properties.Name -contains "barnhk@cckit") {
        $json.plugins.PSObject.Properties.Remove("barnhk@cckit")
        $json | ConvertTo-Json -Depth 4 | Set-Content $installedPath -NoNewline
        Write-Host "  Removed barnhk from installed_plugins.json" -ForegroundColor Gray
    } else {
        Write-Host "  Not found in installed_plugins.json" -ForegroundColor Gray
    }
}

# 4. Verify repo plugin.json
Write-Host "[4/4] Verifying repo plugin.json..." -ForegroundColor Yellow
$repoPlugin = "$PSScriptRoot\hooks\barnhk\.claude-plugin\plugin.json"
$content = Get-Content $repoPlugin -Raw
$hasSh = $content -match '\.sh"'
$hasPs1 = $content -match '\.ps1"'
$hasPwsh = $content -match 'powershell'
Write-Host "  .sh hooks: $hasSh" -ForegroundColor $(if ($hasSh) { 'Green' } else { 'Red' })
Write-Host "  .ps1 refs: $hasPs1" -ForegroundColor $(if ($hasPs1) { 'Red' } else { 'Green' })
Write-Host "  powershell: $hasPwsh" -ForegroundColor $(if ($hasPwsh) { 'Yellow' } else { 'Green' })

# Reinstall
Write-Host ""
Write-Host "=== Reinstalling ===" -ForegroundColor Cyan
claude plugin install barnhk@cckit --scope user 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "  OK" -ForegroundColor Green
} else {
    Write-Host "  FAILED with exit $LASTEXITCODE" -ForegroundColor Red
}

Write-Host ""
Write-Host "Restart Claude Code for clean hooks." -ForegroundColor Green
