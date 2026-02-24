#!/usr/bin/env bash
# permission-request.sh - PermissionRequest hook for auto-approval
# Receives JSON via stdin, can output JSON to auto-approve

set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Load config
load_config

# Read JSON input
INPUT=$(cat)

# Extract permission details
PERMISSION_NAME=$(echo "$INPUT" | json_value '.permission.name')
COMMAND=$(echo "$INPUT" | json_value '.permission.command')
FILE_PATH=$(echo "$INPUT" | json_value '.permission.path')
SESSION_ID=$(echo "$INPUT" | json_value '.session_id')

# Truncate long commands for readability
TRUNCATED_CMD=$(truncate_string "$COMMAND" 100)

# Build tool type label
TOOL_LABEL="[$(echo "$PERMISSION_NAME" | tr '[:lower:]' '[:upper:]')]"

# Check if this is a bash command permission
if [[ "$PERMISSION_NAME" == "bash" ]] && [[ -n "$COMMAND" ]]; then
    # Check if command is in safe whitelist
    if is_safe_command "$COMMAND"; then
        # Build auto-approval notification
        BODY="$TOOL_LABEL Auto-approved\nCmd: $TRUNCATED_CMD"
        send_bark_notification "claude-permit" "$TITLE_PERMIT" "$BODY"

        # Output approval JSON
        echo '{"decision": "allow"}'
        exit 0
    fi
fi

# Build manual approval notification with details
BODY="$TOOL_LABEL Manual approval needed"
if [[ -n "$COMMAND" ]]; then
    BODY="$BODY\nCmd: $TRUNCATED_CMD"
fi
if [[ -n "$FILE_PATH" ]]; then
    BODY="$BODY\nPath: $FILE_PATH"
fi
if [[ -n "$SESSION_ID" ]]; then
    # Show last 8 chars of session ID for brevity
    SHORT_SESSION="${SESSION_ID: -8}"
    BODY="$BODY\nSession: $SHORT_SESSION"
fi

send_bark_notification "claude-permit" "$TITLE_PERMIT" "$BODY"
exit 0
