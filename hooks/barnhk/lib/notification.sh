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
        *) echo "🔔" ;;
    esac
}

# Build notification body: icon + truncated message
ICON=$(get_icon "$NOTIFICATION_TYPE")
TRUNCATED_MSG=$(truncate_message "${MESSAGE:-Claude needs your attention}")
NOTIF_BODY="$ICON $TRUNCATED_MSG"

if [[ -n "$SESSION_ID" ]]; then
    NOTIF_BODY="$NOTIF_BODY"$'\n'"Session: $SESSION_ID"
fi

# Send notification
send_notification "claude-question" "$TITLE_QUESTION" "$NOTIF_BODY"

exit 0
