#!/usr/bin/env bash
# teammate-idle.sh - TeammateIdle hook for teammate idle notifications
# Receives JSON via stdin

set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Load config
load_config

# Read JSON input
INPUT=$(cat)

# Extract teammate info
TEAMMATE_NAME=$(echo "$INPUT" | json_value '.teammate_name')
TEAMMATE_ID=$(echo "$INPUT" | json_value '.teammate_id')

# Build notification body
BODY="Teammate idle"
if [[ -n "$TEAMMATE_NAME" ]]; then
    BODY="Teammate: $TEAMMATE_NAME"
elif [[ -n "$TEAMMATE_ID" ]]; then
    BODY="Teammate ID: $TEAMMATE_ID"
fi

# Send idle notification
send_notification "claude-idle" "$TITLE_IDLE" "$BODY"

exit 0
