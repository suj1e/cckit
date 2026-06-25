# Quick test of the regex replacement
$sample = '"\"${CLAUDE_PLUGIN_ROOT}\"/lib/pre-tool-use.sh"'

Write-Host "Input:  $sample"

# Step 1: .sh -> .ps1
$result = $sample -replace '\.sh"', '.ps1"'
Write-Host "Step1:  $result"

# Step 2: Wrap with powershell
# Match \" before ${CLAUDE_PLUGIN_ROOT} and prepend powershell command
# In raw text: \" (one backslash, one double-quote)
# In regex: \\" (escape backslash, literal double-quote)
$result = $result -replace '\\"\$\{CLAUDE_PLUGIN_ROOT\}', 'powershell -NoProfile -ExecutionPolicy Bypass -File \"${CLAUDE_PLUGIN_ROOT}'
Write-Host "Step2:  $result"
Write-Host ""

# Verify: does it look right?
Write-Host "Expected: `"powershell -NoProfile -ExecutionPolicy Bypass -File \`"`${CLAUDE_PLUGIN_ROOT}`\"/lib/pre-tool-use.ps1`""
Write-Host "Got:      $result"
