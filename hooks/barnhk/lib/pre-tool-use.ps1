#!/usr/bin/env bash
# Bash wrapper: delegates to .sh version
exec bash "$(dirname "$0")/$(basename "$0" .ps1).sh" "$@"
exit
# ==============================================================================
# pre-tool-use.ps1 - PreToolUse hook for dangerous command detection (PowerShell reference)
# Receives JSON via stdin, exits 0 to allow, exit 2 to block
# ==============================================================================

$ErrorActionPreference = "Stop"

# Import common module
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Import-Module (Join-Path $ScriptDir "common.psm1") -Force

# Read JSON input
$input = Read-StdinJson
$toolName = Get-JsonValue -Obj $input -Property "tool_name"
$command = Get-JsonValue -Obj $input -Property "tool_input"
if ($command) {
    $command = Get-JsonValue -Obj $command -Property "command"
}
$cwd = Get-JsonValue -Obj $input -Property "cwd"

# Extract project name
$projectName = ""
if ($cwd) {
    $projectName = Split-Path -Leaf $cwd
}

# Only check Bash tool commands
if ($toolName -ne "Bash" -or -not $command) {
    exit 0
}

# Check danger level
$dangerLevel = Get-DangerLevel -Command $command
$cfg = Import-BarnhkConfig

switch ($dangerLevel) {
    "critical" {
        $reason = "Critical dangerous command detected: $command"
        [Console]::Error.WriteLine("BLOCKED: $reason")
        Send-Notification -Group "claude-danger" -Title $cfg.TITLE_DANGER -Body "Blocked: $command" -ProjectName $projectName
        $output = @{
            hookSpecificOutput = @{
                hookEventName       = "PreToolUse"
                permissionDecision         = "deny"
                permissionDecisionReason    = $reason
            }
        } | ConvertTo-Json -Compress
        Write-Output $output
        exit 2
    }
    "high" {
        $reason = "High-risk command detected: $command"
        [Console]::Error.WriteLine("BLOCKED: $reason")
        Send-Notification -Group "claude-danger" -Title $cfg.TITLE_DANGER -Body "Blocked: $command" -ProjectName $projectName
        $output = @{
            hookSpecificOutput = @{
                hookEventName       = "PreToolUse"
                permissionDecision         = "deny"
                permissionDecisionReason    = $reason
            }
        } | ConvertTo-Json -Compress
        Write-Output $output
        exit 2
    }
    default {
        # medium or safe: allow
        exit 0
    }
}

exit 0
