#!/usr/bin/env bash
# stop.sh - Stop hook for session end notifications
# Receives JSON via stdin

set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Load config
load_config

# Read JSON input
INPUT=$(cat)

# Extract stop info
SESSION_ID=$(echo "$INPUT" | json_value '.session_id')
STOP_REASON=$(echo "$INPUT" | json_value '.reason')

# Build notification body
BODY="Session: ${SESSION_ID:-unknown}"
if [[ -n "$STOP_REASON" ]]; then
    BODY="$BODY\nReason: $STOP_REASON"
fi

# Send stop notification
send_bark_notification "claude-stop" "$TITLE_STOP" "$BODY"

exit 0
