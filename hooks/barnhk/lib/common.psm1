# ==============================================================================
# common.psm1 - Shared functions for barnhk PowerShell hooks
# ==============================================================================

# Load configuration
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ConfigPath = Join-Path $ScriptDir "barnhk.psd1"

# Config hashtable (loaded on import)
$Config = $null

function Import-BarnhkConfig {
    if ($Config) { return $Config }
    if (Test-Path $ConfigPath) {
        $Config = Import-PowerShellDataFile $ConfigPath
    } else {
        # Fallback defaults
        $Config = @{
            BARK_SERVER_URL = ""
            DISCORD_WEBHOOK_URL = ""
            FEISHU_WEBHOOK_URL = ""
            AUTO_APPROVE_PROJECT_COMMANDS = $true
            NOTIFICATION_PERMISSION_PROMPT = "skip"
            NOTIFICATION_QUESTION = "transcript"
            NOTIFICATION_IDLE_PROMPT = "transcript"
            DEBUG_ENABLED = $false
            SAFE_COMMANDS = @()
            DISCORD_COLOR_DANGER = "15548997"
            DISCORD_COLOR_PERMIT = "5763719"
            DISCORD_COLOR_DONE = "3066993"
            DISCORD_COLOR_STOP = "15105570"
            DISCORD_COLOR_IDLE = "8421504"
            TITLE_DANGER = "⚠️ Claude Danger"
            TITLE_PERMIT = "🔔 Claude Permit"
            TITLE_APPROVAL = "🔐 Claude Approval"
            TITLE_DONE = "✅ Claude Done"
            TITLE_STOP = "🛑 Claude Stop"
            TITLE_IDLE = "💤 Teammate Idle"
            TITLE_QUESTION = "❓ Claude Question"
            TITLE_IDLE_PROMPT = "⏳ Claude Waiting"
        }
    }
    return $Config
}

# ==============================================================================
# JSON Helpers
# ==============================================================================

# Read JSON from stdin
function Read-StdinJson {
    $raw = [Console]::In.ReadToEnd()
    if ([string]::IsNullOrWhiteSpace($raw)) { return $null }
    try {
        return $raw | ConvertFrom-Json
    } catch {
        return $null
    }
}

# Get JSON property safely (returns $null if missing)
function Get-JsonValue {
    param($Obj, [string]$Property)
    if ($null -eq $Obj) { return $null }
    $props = $Obj.PSObject.Properties
    if ($props.Name -contains $Property) {
        return $Obj.$Property
    }
    return $null
}

# ==============================================================================
# String Helpers
# ==============================================================================

# Truncate string to max length
function ConvertTo-TruncatedString {
    param([string]$Str, [int]$MaxLen = 100)
    if (-not $Str) { return "" }
    if ($Str.Length -gt $MaxLen) {
        return $Str.Substring(0, $MaxLen) + "..."
    }
    return $Str
}

# URL encode a string
function ConvertTo-UrlEncoded {
    param([string]$Str)
    if (-not $Str) { return "" }
    return [System.Web.HttpUtility]::UrlEncode($Str)
}

# ==============================================================================
# Notification Icon / Color Helpers
# ==============================================================================

function Get-NotificationIcon {
    param([string]$Type)
    switch ($Type) {
        "permission_prompt" { return "🔐" }
        "question"          { return "❓" }
        "idle_prompt"       { return "⏳" }
        default             { return "🔔" }
    }
}

function Get-DiscordColor {
    param([string]$Group)
    $cfg = Import-BarnhkConfig
    switch ($Group) {
        "claude-danger"         { return $cfg.DISCORD_COLOR_DANGER }
        "claude-permit"         { return $cfg.DISCORD_COLOR_PERMIT }
        "claude-auto-permit"    { return $cfg.DISCORD_COLOR_PERMIT }
        "claude-manual-permit"  { return "16776960" }
        "claude-done"           { return $cfg.DISCORD_COLOR_DONE }
        "claude-stop"           { return $cfg.DISCORD_COLOR_STOP }
        "claude-idle"           { return $cfg.DISCORD_COLOR_IDLE }
        "claude-question"       { return "10181046" }
        default                 { return "7506394" }
    }
}

function Get-FeishuColor {
    param([string]$Group)
    switch ($Group) {
        "claude-danger"         { return "red" }
        "claude-permit"         { return "green" }
        "claude-auto-permit"    { return "green" }
        "claude-manual-permit"  { return "yellow" }
        "claude-done"           { return "blue" }
        "claude-stop"           { return "orange" }
        "claude-idle"           { return "grey" }
        "claude-question"       { return "purple" }
        default                 { return "blue" }
    }
}

function Get-FieldIcon {
    param([string]$Field)
    switch ($Field) {
        "Cmd"     { return "⌨️" }
        "Path"    { return "📁" }
        "Session" { return "🔗" }
        "Reason"  { return "💡" }
        "Tool"    { return "🔧" }
        default   { return "📌" }
    }
}

# ==============================================================================
# Bark Notification
# ==============================================================================

function Send-BarkNotification {
    param(
        [string]$Group,
        [string]$Title,
        [string]$Body
    )
    $cfg = Import-BarnhkConfig
    $serverUrl = $cfg.BARK_SERVER_URL

    if ([string]::IsNullOrEmpty($serverUrl)) { return }
    if ($serverUrl -notmatch "^https?://") { return }

    # Determine sound based on group
    $sound = ""
    switch ($Group) {
        "claude-danger" { $sound = "alarm.caf" }
        "claude-permit" { $sound = "bell.caf" }
        "claude-done"   { $sound = "glass.caf" }
    }

    # Build URL with manual URL encoding (avoid System.Web dependency)
    $encTitle = [uri]::EscapeDataString($Title)
    $encBody = [uri]::EscapeDataString($Body)
    $encGroup = [uri]::EscapeDataString($Group)

    $url = $serverUrl.TrimEnd('/') + "/" + $encTitle + "/" + $encBody + "?group=" + $encGroup
    if ($sound) {
        $url += "&sound=" + $sound
    }

    try {
        Invoke-WebRequest -Uri $url -Method Get -TimeoutSec 3 -ErrorAction SilentlyContinue | Out-Null
    } catch {
        # Silent failure
    }
}

# ==============================================================================
# Discord Notification
# ==============================================================================

function Send-DiscordNotification {
    param(
        [string]$Group,
        [string]$Title,
        [string]$Body
    )
    $cfg = Import-BarnhkConfig
    $webhookUrl = $cfg.DISCORD_WEBHOOK_URL

    if ([string]::IsNullOrEmpty($webhookUrl)) { return }
    if ($webhookUrl -notmatch "^https?://") { return }

    $color = Get-DiscordColor -Group $Group

    # Build embed JSON
    $payload = @{
        embeds = @(
            @{
                title       = $Title
                description = $Body
                color       = [int]$color
                footer      = @{ text = $Group }
            }
        )
    } | ConvertTo-Json -Depth 4

    try {
        Invoke-WebRequest -Uri $webhookUrl -Method Post -ContentType "application/json" -Body $payload -TimeoutSec 5 -ErrorAction SilentlyContinue | Out-Null
    } catch {
        # Silent failure
    }
}

# ==============================================================================
# Feishu Notification
# ==============================================================================

function ConvertTo-FeishuElements {
    param(
        [string]$Group,
        [string]$Body
    )
    # Parse body into lines
    $lines = $Body -split "`n" | Where-Object { $_.Trim() -ne "" }
    $elements = @()

    $firstLine = ""
    $fields = @()
    $lineNum = 0

    foreach ($line in $lines) {
        $lineNum++
        if ($lineNum -eq 1) {
            $firstLine = "📋 " + $line
            continue
        }
        # Check for "Key: Value" pattern
        if ($line -match '^([^:]+):\ (.+)$') {
            $key = $Matches[1]
            $value = $Matches[2]
            $icon = Get-FieldIcon -Field $key
            $label = "$icon $key"

            $field = @{
                tag  = "div"
                text = @{
                    tag     = "lark_md"
                    content = "**$label**  `n$value"
                }
            }
            $fields += $field
        }
    }

    if ($fields.Count -gt 0) {
        # Structured format
        $elements += @{
            tag  = "div"
            text = @{
                tag     = "plain_text"
                content = $firstLine
            }
        }
        $elements += @{ tag = "hr" }
        $elements += $fields
    } else {
        # Fallback: simple format
        $elements += @{
            tag  = "div"
            text = @{
                tag     = "plain_text"
                content = $Body
            }
        }
    }

    # Footer note
    $elements += @{
        tag      = "note"
        elements = @(
            @{
                tag     = "plain_text"
                content = $Group
            }
        )
    }

    return $elements
}

function Send-FeishuNotification {
    param(
        [string]$Group,
        [string]$Title,
        [string]$Body
    )
    $cfg = Import-BarnhkConfig
    $webhookUrl = $cfg.FEISHU_WEBHOOK_URL

    if ([string]::IsNullOrEmpty($webhookUrl)) { return }
    if ($webhookUrl -notmatch "^https?://") { return }

    $color = Get-FeishuColor -Group $Group
    $elements = ConvertTo-FeishuElements -Group $Group -Body $Body

    $payload = @{
        msg_type = "interactive"
        card     = @{
            header   = @{
                title    = @{
                    tag     = "plain_text"
                    content = $Title
                }
                template = $color
            }
            elements = $elements
        }
    } | ConvertTo-Json -Depth 6

    try {
        Invoke-WebRequest -Uri $webhookUrl -Method Post -ContentType "application/json" -Body $payload -TimeoutSec 5 -ErrorAction SilentlyContinue | Out-Null
    } catch {
        # Silent failure
    }
}

# ==============================================================================
# Unified Notification Dispatcher
# ==============================================================================

function Send-Notification {
    param(
        [string]$Group,
        [string]$Title,
        [string]$Body,
        [string]$ProjectName = ""
    )

    # Prepend project name to title if provided
    if ($ProjectName) {
        $Title = "[$ProjectName] $Title"
    }

    Send-BarkNotification -Group $Group -Title $Title -Body $Body
    Send-DiscordNotification -Group $Group -Title $Title -Body $Body
    Send-FeishuNotification -Group $Group -Title $Title -Body $Body
}

# ==============================================================================
# Safe Command / Danger Level Checking
# ==============================================================================

function Test-SafeCommand {
    param(
        [string]$Command,
        [string]$Cwd = ""
    )
    $cfg = Import-BarnhkConfig

    # Project directory auto-approve (if enabled)
    if ($cfg.AUTO_APPROVE_PROJECT_COMMANDS -and $Cwd) {
        return $true
    }

    # Git commands
    if ($Command -match '^git\s+(status|log|diff|add|commit|push|pull|checkout|merge|rebase|branch|fetch|stash|reset|restore|switch|show)') {
        return $true
    }

    # Package managers
    if ($Command -match '^(npm|pnpm|yarn|pip)\s+(install|run|test|build|start|dev|ci)') {
        return $true
    }

    # Build tools
    if ($Command -match '^(gradle|mvn|cargo)\s') {
        return $true
    }

    # File read operations
    if ($Command -match '^(ls|cat|grep|find|head|tail|wc|sort|uniq|cut|awk|sed)\s') {
        return $true
    }
    if ($Command -match '^(ls|cat|grep|find|head|tail)$') {
        return $true
    }

    # OpenSpec workflow commands
    if ($Command -match '^openspec\s+') {
        return $true
    }

    # Directory / file operations
    if ($Command -match '^mkdir\s+') { return $true }
    if ($Command -match '^(touch|cp|mv)\s+') { return $true }

    # Docker read-only commands
    if ($Command -match '^docker\s+(ps|ls|images|logs|inspect|stats|top|port|exec)(\s|$)') {
        return $true
    }
    if ($Command -match '^docker\s+(network|volume)\s+ls') {
        return $true
    }
    # Docker compose
    if ($Command -match '^docker-compose\s+(up|down|logs|ps|build|config)\s+') {
        return $true
    }
    if ($Command -match '^docker\s+compose\s+(up|down|logs|ps|build|config)\s+') {
        return $true
    }

    # Custom whitelist from config
    foreach ($pattern in $cfg.SAFE_COMMANDS) {
        if ($Command -match $pattern) {
            return $true
        }
    }

    return $false
}

function Get-DangerLevel {
    param([string]$Command)

    # Critical level - always block
    if ($Command -match 'rm\s+-rf\s+(/|/\*)') {
        return "critical"
    }
    if ($Command -match 'dd\s+.*of=/dev/') {
        return "critical"
    }
    if ($Command -match 'mkfs\s') {
        return "critical"
    }

    # High level - block
    if ($Command -match '^sudo\s') {
        return "high"
    }
    if ($Command -match '(curl|wget).*\|[ ]*(bash|sh)') {
        return "high"
    }
    if ($Command -match 'chmod\s+-R\s+777') {
        return "high"
    }
    if ($Command -match 'chmod\s+777\s+/') {
        return "high"
    }

    # Medium level - allow (no action needed)
    if ($Command -match '(nc|netcat)\s+-l') {
        return "medium"
    }
    if ($Command -match 'kill\s+-9\s+-1') {
        return "medium"
    }
    if ($Command -match 'pkill\s+-f') {
        return "medium"
    }

    return "safe"
}

# ==============================================================================
# Notification Mode / Title Helpers
# ==============================================================================

function Get-NotificationMode {
    param([string]$Type)
    $cfg = Import-BarnhkConfig
    switch ($Type) {
        "permission_prompt" { return $cfg.NOTIFICATION_PERMISSION_PROMPT }
        "question"          { return $cfg.NOTIFICATION_QUESTION }
        "idle_prompt"       { return $cfg.NOTIFICATION_IDLE_PROMPT }
        default             { return "default" }
    }
}

function Get-NotificationTitle {
    param([string]$Type)
    $cfg = Import-BarnhkConfig
    switch ($Type) {
        "question"    { return $cfg.TITLE_QUESTION }
        "idle_prompt" { return $cfg.TITLE_IDLE_PROMPT }
        default       { return $cfg.TITLE_QUESTION }
    }
}

# ==============================================================================
# Transcript Content Extraction
# ==============================================================================

function Get-TranscriptContent {
    param(
        [string]$TranscriptPath,
        [string]$SessionId,
        [int]$MaxLen = 200
    )
    $debugPath = Join-Path $env:TEMP "barnhk-transcript-debug.log"

    function Write-DebugLog {
        param([string]$Msg)
        $cfg = Import-BarnhkConfig
        if (-not $cfg.DEBUG_ENABLED) { return }
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        "[$timestamp] $Msg" | Out-File -FilePath $debugPath -Append -Encoding UTF8 -ErrorAction SilentlyContinue
    }

    Write-DebugLog "=== Get-TranscriptContent called ==="
    Write-DebugLog "TranscriptPath: $TranscriptPath"
    Write-DebugLog "SessionId: $SessionId"

    if (-not (Test-Path $TranscriptPath)) {
        Write-DebugLog "ERROR: transcript file not found"
        return $null
    }

    # Read last 30 lines and search for matching assistant text
    try {
        $lines = Get-Content $TranscriptPath -Tail 30
    } catch {
        Write-DebugLog "ERROR: failed to read transcript"
        return $null
    }

    # Reverse to process newest first
    [array]::Reverse($lines)

    $lineCount = 0
    $matchedLines = 0
    $extractedText = ""

    foreach ($line in $lines) {
        if ([string]::IsNullOrWhiteSpace($line)) { continue }

        $lineCount++
        if ($lineCount -gt 30) { break }

        try {
            $obj = $line | ConvertFrom-Json
        } catch {
            continue
        }

        # Try both sessionId and session_id field names
        $lineSession = Get-JsonValue -Obj $obj -Property "sessionId"
        if (-not $lineSession) {
            $lineSession = Get-JsonValue -Obj $obj -Property "session_id"
        }

        if ($lineSession -ne $SessionId) { continue }
        $matchedLines++

        # Check if this is an assistant message
        $msgType = Get-JsonValue -Obj $obj -Property "type"
        if ($msgType -ne "assistant") { continue }

        # Try multiple extraction patterns
        $textContent = $null

        # Pattern 1: .message.content[] | select(.type == "text") | .text
        $message = Get-JsonValue -Obj $obj -Property "message"
        if ($message) {
            $content = Get-JsonValue -Obj $message -Property "content"
            if ($content) {
                foreach ($block in $content) {
                    if ((Get-JsonValue -Obj $block -Property "type") -eq "text") {
                        $t = Get-JsonValue -Obj $block -Property "text"
                        if ($t) { $textContent = $t }
                    }
                }
            }
            # Pattern 3: .message.text (simple text field)
            if (-not $textContent) {
                $textContent = Get-JsonValue -Obj $message -Property "text"
            }
        }

        # Pattern 2: .content[] without .message wrapper
        if (-not $textContent) {
            $content = Get-JsonValue -Obj $obj -Property "content"
            if ($content) {
                foreach ($block in $content) {
                    if ((Get-JsonValue -Obj $block -Property "type") -eq "text") {
                        $t = Get-JsonValue -Obj $block -Property "text"
                        if ($t) { $textContent = $t }
                    }
                }
            }
        }

        # Pattern 4: .text (direct text field)
        if (-not $textContent) {
            $textContent = Get-JsonValue -Obj $obj -Property "text"
        }

        if ($textContent) {
            Write-DebugLog "Line $lineCount : extracted text ($($textContent.Length) chars)"
            $extractedText = $textContent
        }
    }

    Write-DebugLog "Processed $lineCount lines, $matchedLines session matches"

    if ($extractedText) {
        # Remove newlines for notification display
        $extractedText = $extractedText -replace '\s+', ' '
        if ($extractedText.Length -gt $MaxLen) {
            return $extractedText.Substring(0, $MaxLen) + "..."
        }
        Write-DebugLog "SUCCESS: returning text ($($extractedText.Length) chars)"
        return $extractedText
    }

    Write-DebugLog "FAILURE: no text extracted"
    return $null
}

# ==============================================================================
# Debug Logging
# ==============================================================================

function Write-PermissionDebugLog {
    param([string]$Msg)
    $cfg = Import-BarnhkConfig
    if (-not $cfg.DEBUG_ENABLED) { return }
    $debugPath = Join-Path $env:TEMP "barnhk-permission-debug.log"
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "[$timestamp] $Msg" | Out-File -FilePath $debugPath -Append -Encoding UTF8 -ErrorAction SilentlyContinue
}

# Initialize config on module load
Import-BarnhkConfig | Out-Null
