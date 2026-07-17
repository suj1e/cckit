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

# Extract task info (current spec fields)
TASK_ID=$(echo "$INPUT" | json_value '.task_id')
TASK_SUBJECT=$(echo "$INPUT" | json_value '.task_subject')
TASK_DESCRIPTION=$(echo "$INPUT" | json_value '.task_description')
TEAMMATE_NAME=$(echo "$INPUT" | json_value '.teammate_name')
TEAM_NAME=$(echo "$INPUT" | json_value '.team_name')
CWD=$(echo "$INPUT" | json_value '.cwd')

# Extract project name (from cwd or fallback to $PWD)
PROJECT_NAME=""
if [[ -n "$CWD" ]]; then
    PROJECT_NAME=$(basename "$CWD")
elif [[ -n "$PWD" ]]; then
    PROJECT_NAME=$(basename "$PWD")
fi

# Build notification body
BODY="Task completed"
if [[ -n "$TASK_SUBJECT" ]]; then
    BODY="$BODY"$'\n'"Subject: $TASK_SUBJECT"
fi
if [[ -n "$TASK_ID" ]]; then
    BODY="$BODY"$'\n'"Task ID: $TASK_ID"
fi
if [[ -n "$TEAMMATE_NAME" ]]; then
    BODY="$BODY"$'\n'"By: $TEAMMATE_NAME"
fi
if [[ -n "$TEAM_NAME" ]]; then
    BODY="$BODY"$'\n'"Team: $TEAM_NAME"
fi

# Send completion notification
send_notification "claude-done" "$TITLE_DONE" "$BODY" "$PROJECT_NAME"

exit 0
