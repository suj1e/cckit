# Directly patch the repo's plugin.json for Windows testing
$pluginJson = "$PSScriptRoot\hooks\barnhk\.claude-plugin\plugin.json"

# Restore from the original .sh version first
Copy-Item "$PSScriptRoot\hooks\barnhk\.claude-plugin\plugin.json.json" $pluginJson -Force

# Parse and patch
$json = Get-Content $pluginJson -Raw | ConvertFrom-Json
$hookContainer = $json.hooks

foreach ($hookName in $hookContainer.PSObject.Properties.Name) {
    $hookList = $hookContainer.$hookName
    foreach ($entry in $hookList) {
        foreach ($hook in $entry.hooks) {
            $cmd = $hook.command
            Write-Host "BEFORE: $cmd"
            if ($cmd -match '\.sh"$') {
                $newCmd = $cmd -replace '\.sh"$', '.ps1"'
                $newCmd = 'powershell -NoProfile -ExecutionPolicy Bypass -File ' + $newCmd
                $hook.command = $newCmd
                Write-Host "AFTER:  $newCmd"
            }
        }
    }
}

$json | ConvertTo-Json -Depth 6 | Set-Content $pluginJson -NoNewline
Write-Host ""
Write-Host "Done. Check the result:"
Get-Content $pluginJson | Select-String "command"
