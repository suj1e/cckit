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

# Extract teammate info (current spec fields)
TEAMMATE_NAME=$(echo "$INPUT" | json_value '.teammate_name')
TEAM_NAME=$(echo "$INPUT" | json_value '.team_name')
CWD=$(echo "$INPUT" | json_value '.cwd')

# Extract project name from cwd
PROJECT_NAME=""
if [[ -n "$CWD" ]]; then
    PROJECT_NAME=$(basename "$CWD")
fi

# Build notification body
BODY="Teammate idle"
if [[ -n "$TEAMMATE_NAME" ]]; then
    BODY="Teammate: $TEAMMATE_NAME"
fi
if [[ -n "$TEAM_NAME" ]]; then
    BODY="$BODY"$'\n'"Team: $TEAM_NAME"
fi

# Send idle notification
send_notification "claude-idle" "$TITLE_IDLE" "$BODY" "$PROJECT_NAME"

exit 0
