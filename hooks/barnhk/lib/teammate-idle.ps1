#!/usr/bin/env bash
# Bash wrapper: delegates to .sh version
exec bash "$(dirname "$0")/$(basename "$0" .ps1).sh" "$@"
exit
# ==============================================================================
# teammate-idle.ps1 - TeammateIdle hook for teammate idle notifications (PowerShell reference)
# Receives JSON via stdin
# ==============================================================================

$ErrorActionPreference = "Stop"

# Import common module
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Import-Module (Join-Path $ScriptDir "common.psm1") -Force

# Read JSON input
$input = Read-StdinJson

$teammateName = Get-JsonValue -Obj $input -Property "teammate_name"
$teamName = Get-JsonValue -Obj $input -Property "team_name"
$cwd = Get-JsonValue -Obj $input -Property "cwd"

# Extract project name
$projectName = ""
if ($cwd) {
    $projectName = Split-Path -Leaf $cwd
}

# Build notification body
$body = "Teammate idle"
if ($teammateName) {
    $body = "Teammate: $teammateName"
}
if ($teamName) {
    $body += "`nTeam: $teamName"
}

$cfg = Import-BarnhkConfig
Send-Notification -Group "claude-idle" -Title $cfg.TITLE_IDLE -Body $body -ProjectName $projectName

exit 0
