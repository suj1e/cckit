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
CWD=$(echo "$INPUT" | json_value '.cwd')

# Extract project name from cwd
PROJECT_NAME=""
if [[ -n "$CWD" ]]; then
    PROJECT_NAME=$(basename "$CWD")
fi

# Build notification body
BODY="Session: ${SESSION_ID:-unknown}"
if [[ -n "$STOP_REASON" ]]; then
    BODY="$BODY"$'\n'"Reason: $STOP_REASON"
fi

# Send stop notification
send_notification "claude-stop" "$TITLE_STOP" "$BODY" "$PROJECT_NAME"

exit 0
