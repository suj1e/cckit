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

# Extract stop info (current spec fields)
SESSION_ID=$(echo "$INPUT" | json_value '.session_id')
LAST_MESSAGE=$(echo "$INPUT" | json_value '.last_assistant_message')
CWD=$(echo "$INPUT" | json_value '.cwd')

# Extract project name from cwd
PROJECT_NAME=""
if [[ -n "$CWD" ]]; then
    PROJECT_NAME=$(basename "$CWD")
fi

# Build notification body
BODY="Session: ${SESSION_ID:-unknown}"
if [[ -n "$LAST_MESSAGE" ]]; then
    TRUNCATED_MSG=$(truncate_string "$LAST_MESSAGE" 200)
    BODY="$BODY"$'\n'"Message: $TRUNCATED_MSG"
fi

# Send stop notification
send_notification "claude-stop" "$TITLE_STOP" "$BODY" "$PROJECT_NAME"

exit 0
