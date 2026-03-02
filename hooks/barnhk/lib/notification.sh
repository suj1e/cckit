#!/usr/bin/env bash
# notification.sh - Notification hook for Claude notifications
# Receives JSON via stdin

set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Load config
load_config

# Read JSON input
INPUT=$(cat)

# Extract notification info (actual format from Claude Code)
SESSION_ID=$(echo "$INPUT" | json_value '.session_id')
MESSAGE=$(echo "$INPUT" | json_value '.message')
NOTIFICATION_TYPE=$(echo "$INPUT" | json_value '.notification_type')
CWD=$(echo "$INPUT" | json_value '.cwd')
TRANSCRIPT_PATH=$(echo "$INPUT" | json_value '.transcript_path')

# Extract project name from cwd
PROJECT_NAME=""
if [[ -n "$CWD" ]]; then
    PROJECT_NAME=$(basename "$CWD")
fi

# Get handling mode for this notification type
MODE=$(get_notification_mode "$NOTIFICATION_TYPE")

# Skip if mode is "skip"
if [[ "$MODE" == "skip" ]]; then
    exit 0
fi

# Truncate message to 200 characters
truncate_message() {
    local msg="$1"
    local max_len=200
    if [[ ${#msg} -gt $max_len ]]; then
        echo "${msg:0:$max_len}..."
    else
        echo "$msg"
    fi
}

# Get icon prefix based on notification type
get_icon() {
    case "$1" in
        permission_prompt) echo "🔐" ;;
        question) echo "❓" ;;
        idle_prompt) echo "⏳" ;;
        *) echo "🔔" ;;
    esac
}

# Determine notification content based on mode
NOTIF_CONTENT=""
if [[ "$MODE" == "transcript" ]] && [[ -n "$TRANSCRIPT_PATH" ]] && [[ -n "$SESSION_ID" ]]; then
    # Try to extract specific content from transcript
    NOTIF_CONTENT=$(extract_transcript_content "$TRANSCRIPT_PATH" "$SESSION_ID" 200 2>/dev/null) || true
fi

# Fallback to generic message if extraction failed or mode is "default"
if [[ -z "$NOTIF_CONTENT" ]]; then
    NOTIF_CONTENT=$(truncate_message "${MESSAGE:-Claude needs your attention}")
fi

# Build notification body: icon + content
ICON=$(get_icon "$NOTIFICATION_TYPE")
NOTIF_BODY="$ICON $NOTIF_CONTENT"

if [[ -n "$SESSION_ID" ]]; then
    NOTIF_BODY="$NOTIF_BODY"$'\n'"Session: $SESSION_ID"
fi

# Send notification
send_notification "claude-question" "$TITLE_QUESTION" "$NOTIF_BODY" "$PROJECT_NAME"

exit 0
