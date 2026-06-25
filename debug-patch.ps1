# Debug the JSON patching
$pluginJson = "$PSScriptRoot\hooks\barnhk\.claude-plugin\plugin.json"

# Step 1: Restore from original .sh
Copy-Item "$PSScriptRoot\hooks\barnhk\.claude-plugin\plugin.json.json" $pluginJson -Force

# Step 2: Parse
$raw = Get-Content $pluginJson -Raw
$json = $raw | ConvertFrom-Json

# Step 3: Check parsed values
$firstHook = $json.hooks.PreToolUse[0].hooks[0]
Write-Host "Parsed command value: [$($firstHook.command)]"
Write-Host "Length: $($firstHook.command.Length)"
Write-Host "Ends with .sh quote?: $($firstHook.command -match '\.sh$')"

# Display char codes at end
$cmd = $firstHook.command
Write-Host "Last 5 chars:"
for ($i = $cmd.Length - 5; $i -lt $cmd.Length; $i++) {
    Write-Host "  [$i] '$($cmd[$i])' (0x$([int]$cmd[$i]:x4))"
}
