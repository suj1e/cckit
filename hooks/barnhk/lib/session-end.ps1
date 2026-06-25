#!/usr/bin/env bash
# Bash wrapper: delegates to .sh version
exec bash "$(dirname "$0")/$(basename "$0" .ps1).sh" "$@"
exit
# ==============================================================================
# session-end.ps1 - SessionEnd hook for session end notifications (PowerShell reference)
# Receives JSON via stdin
# ==============================================================================

$ErrorActionPreference = "Stop"

# Import common module
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Import-Module (Join-Path $ScriptDir "common.psm1") -Force

# Read JSON input
$input = Read-StdinJson

$sessionId = Get-JsonValue -Obj $input -Property "session_id"
$endReason = Get-JsonValue -Obj $input -Property "reason"
$cwd = Get-JsonValue -Obj $input -Property "cwd"

# Extract project name
$projectName = ""
if ($cwd) {
    $projectName = Split-Path -Leaf $cwd
}

# Build notification body
$body = "[SESSION] Session ended"
if ($sessionId) {
    $body += "`nSession: $sessionId"
}
if ($endReason) {
    $body += "`nReason: $endReason"
}

$cfg = Import-BarnhkConfig
Send-Notification -Group "claude-stop" -Title $cfg.TITLE_STOP -Body $body -ProjectName $projectName

exit 0
