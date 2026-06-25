#!/usr/bin/env bash
# Bash wrapper: delegates to .sh version
exec bash "$(dirname "$0")/$(basename "$0" .ps1).sh" "$@"
exit
# ==============================================================================
# stop.ps1 - Stop hook for session stop notifications (PowerShell reference)
# Receives JSON via stdin
# ==============================================================================

$ErrorActionPreference = "Stop"

# Import common module
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Import-Module (Join-Path $ScriptDir "common.psm1") -Force

# Read JSON input
$input = Read-StdinJson

$sessionId = Get-JsonValue -Obj $input -Property "session_id"
$lastMessage = Get-JsonValue -Obj $input -Property "last_assistant_message"
$cwd = Get-JsonValue -Obj $input -Property "cwd"

# Extract project name
$projectName = ""
if ($cwd) {
    $projectName = Split-Path -Leaf $cwd
}

# Build notification body
$body = "Session: "
if ($sessionId) {
    $body += $sessionId
} else {
    $body += "unknown"
}
if ($lastMessage) {
    $truncatedMsg = ConvertTo-TruncatedString -Str $lastMessage -MaxLen 200
    $body += "`nMessage: $truncatedMsg"
}

$cfg = Import-BarnhkConfig
Send-Notification -Group "claude-stop" -Title $cfg.TITLE_STOP -Body $body -ProjectName $projectName

exit 0
