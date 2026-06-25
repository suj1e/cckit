#!/usr/bin/env bash
# notification.ps1 - delegates to .sh
bash "$(dirname "$0")/notification.sh"
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

$sessionId = Get-JsonValue -Obj $input -Property "session_id"
$message = Get-JsonValue -Obj $input -Property "message"
$notificationType = Get-JsonValue -Obj $input -Property "notification_type"
$cwd = Get-JsonValue -Obj $input -Property "cwd"
$transcriptPath = Get-JsonValue -Obj $input -Property "transcript_path"

# Extract project name
$projectName = ""
if ($cwd) {
    $projectName = Split-Path -Leaf $cwd
}

# Get handling mode for this notification type
$mode = Get-NotificationMode -Type $notificationType

# Skip if mode is "skip"
if ($mode -eq "skip") {
    exit 0
}

# Determine notification content
$notifContent = ""
if ($mode -eq "transcript" -and $transcriptPath -and $sessionId) {
    try {
        $extracted = Get-TranscriptContent -TranscriptPath $transcriptPath -SessionId $sessionId -MaxLen 200
        if ($extracted) {
            $notifContent = $extracted
        }
    } catch {
        # Fallback to generic
    }
}

# Fallback to generic message
if (-not $notifContent) {
    if ($message) {
        $notifContent = ConvertTo-TruncatedString -Str $message -MaxLen 200
    } else {
        $notifContent = "Claude needs your attention"
    }
}

# Build notification body
$icon = Get-NotificationIcon -Type $notificationType
$notifBody = "$icon $notifContent"
if ($sessionId) {
    $notifBody += "`nSession: $sessionId"
}

# Send notification
$title = Get-NotificationTitle -Type $notificationType
Send-Notification -Group "claude-question" -Title $title -Body $notifBody -ProjectName $projectName

exit 0
