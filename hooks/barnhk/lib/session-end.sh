#!/usr/bin/env bash
# session-end.sh - SessionEnd hook for session end notifications
# Triggered when Claude Code session ends completely

set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Load config
load_config

# Read JSON input
INPUT=$(cat)

# Extract session info
SESSION_ID=$(echo "$INPUT" | json_value '.session_id')

# Build notification body
BODY="[SESSION] Session ended"
if [[ -n "$SESSION_ID" ]]; then
    # Show last 8 chars of session ID for brevity
    SHORT_SESSION="${SESSION_ID: -8}"
    BODY="$BODY\nSession: $SHORT_SESSION"
fi

# Send session end notification
send_bark_notification "claude-stop" "$TITLE_STOP" "$BODY"

exit 0
