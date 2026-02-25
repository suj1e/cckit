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

# Build notification body based on notification type
case "$NOTIFICATION_TYPE" in
    permission_prompt)
        NOTIF_BODY="🔐 Permission required"
        ;;
    *)
        NOTIF_BODY="${MESSAGE:-Claude needs your attention}"
        ;;
esac

if [[ -n "$SESSION_ID" ]]; then
    NOTIF_BODY="$NOTIF_BODY"$'\n'"Session: $SESSION_ID"
fi

# Send notification
send_notification "claude-question" "$TITLE_QUESTION" "$NOTIF_BODY"

exit 0
