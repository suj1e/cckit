# ==============================================================================
# task-completed.ps1 - TaskCompleted hook for completion notifications
# Receives JSON via stdin
# ==============================================================================

$ErrorActionPreference = "Stop"

# Import common module
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Import-Module (Join-Path $ScriptDir "common.psm1") -Force

# Read JSON input
$input = Read-StdinJson

$taskId = Get-JsonValue -Obj $input -Property "task_id"
$taskSubject = Get-JsonValue -Obj $input -Property "task_subject"
$taskDescription = Get-JsonValue -Obj $input -Property "task_description"
$teammateName = Get-JsonValue -Obj $input -Property "teammate_name"
$teamName = Get-JsonValue -Obj $input -Property "team_name"
$cwd = Get-JsonValue -Obj $input -Property "cwd"

# Extract project name
$projectName = ""
if ($cwd) {
    $projectName = Split-Path -Leaf $cwd
}

# Build notification body
$body = "Task completed"
if ($taskSubject) {
    $body += "`nSubject: $taskSubject"
}
if ($taskId) {
    $body += "`nTask ID: $taskId"
}
if ($teammateName) {
    $body += "`nBy: $teammateName"
}
if ($teamName) {
    $body += "`nTeam: $teamName"
}

$cfg = Import-BarnhkConfig
Send-Notification -Group "claude-done" -Title $cfg.TITLE_DONE -Body $body -ProjectName $projectName

exit 0
