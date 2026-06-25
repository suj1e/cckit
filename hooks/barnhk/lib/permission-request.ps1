#!/usr/bin/env bash
# permission-request.ps1 - delegates to .sh
bash "$(dirname "$0")/permission-request.sh"
exit $?
# ==============================================================================
# (original PowerShell reference below)
# Receives JSON via stdin, outputs JSON to auto-approve
# ==============================================================================

$ErrorActionPreference = "Stop"

# Import common module
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Import-Module (Join-Path $ScriptDir "common.psm1") -Force

# Read JSON input
$input = Read-StdinJson

# Debug logging
Write-PermissionDebugLog "INPUT: $($input | ConvertTo-Json -Compress)"

$toolName = Get-JsonValue -Obj $input -Property "tool_name"
$command = Get-JsonValue -Obj $input -Property "tool_input"
if ($command) {
    $command = Get-JsonValue -Obj $command -Property "command"
}
$filePath = Get-JsonValue -Obj $input -Property "tool_input"
if ($filePath) {
    $filePath = Get-JsonValue -Obj $filePath -Property "file_path"
}
if (-not $filePath) {
    $filePath = Get-JsonValue -Obj $input -Property "tool_input"
    if ($filePath) {
        $filePath = Get-JsonValue -Obj $filePath -Property "path"
    }
}
$sessionId = Get-JsonValue -Obj $input -Property "session_id"
$cwd = Get-JsonValue -Obj $input -Property "cwd"

# Extract project name
$projectName = ""
if ($cwd) {
    $projectName = Split-Path -Leaf $cwd
}

# Truncate long commands for readability
$truncatedCmd = ConvertTo-TruncatedString -Str $command -MaxLen 100
$toolLabel = "[$($toolName.ToUpper())]"
$cfg = Import-BarnhkConfig

# Auto-approve Edit/Write for files within project directory
if (($toolName -eq "Edit" -or $toolName -eq "Write") -and $filePath -and $cwd) {
    if ($filePath.StartsWith($cwd)) {
        [Console]::Error.WriteLine("[barnhk] Auto-approving: $toolName $filePath")
        $output = @{
            hookSpecificOutput = @{
                hookEventName = "PermissionRequest"
                decision      = @{ behavior = "allow" }
            }
        } | ConvertTo-Json -Compress
        Write-Output $output
        exit 0
    }
}

# Check if this is a bash command permission
if ($toolName -eq "Bash" -and $command) {
    if (Test-SafeCommand -Command $command -Cwd $cwd) {
        [Console]::Error.WriteLine("[barnhk] Auto-approving: $command")

        # Output approval JSON
        $output = @{
            hookSpecificOutput = @{
                hookEventName = "PermissionRequest"
                decision      = @{ behavior = "allow" }
            }
        } | ConvertTo-Json -Compress
        Write-Output $output
        Write-PermissionDebugLog "OUTPUT: $output"

        # Send notification (non-blocking)
        $body = "$toolLabel Auto-approved`nCmd: $truncatedCmd"
        Send-Notification -Group "claude-auto-permit" -Title $cfg.TITLE_PERMIT -Body $body -ProjectName $projectName
        exit 0
    }
}

# Build manual approval notification
$body = "$toolLabel Manual approval needed"
if ($command) {
    $body += "`nCmd: $truncatedCmd"
}
if ($filePath) {
    $body += "`nPath: $filePath"
}
if ($sessionId) {
    $body += "`nSession: $sessionId"
}

Send-Notification -Group "claude-manual-permit" -Title $cfg.TITLE_APPROVAL -Body $body -ProjectName $projectName
exit 0
