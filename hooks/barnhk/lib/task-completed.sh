#!/usr/bin/env bash
# task-completed.sh - TaskCompleted hook for completion notifications
# Receives JSON via stdin

set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Load config
load_config

# Read JSON input
INPUT=$(cat)

# Extract task info
SESSION_ID=$(echo "$INPUT" | json_value '.session_id')
TRANSCRIPT_PATH=$(echo "$INPUT" | json_value '.transcript_path')

# Build notification body
BODY="Session: ${SESSION_ID:-unknown}"
if [[ -n "$TRANSCRIPT_PATH" ]]; then
    BODY="$BODY\nTranscript saved"
fi

# Send completion notification
send_bark_notification "claude-done" "$TITLE_DONE" "$BODY"

exit 0
