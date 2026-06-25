#!/usr/bin/env bash
# teammate-idle.ps1 - delegates to .sh
bash "$(dirname "$0")/teammate-idle.sh"
exit $?
# ==============================================================================
# (original PowerShell reference below)
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
