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

# Debug: log input
DEBUG_LOG="/tmp/barnhk-permission-debug.log"
echo "[$(date)] INPUT: $INPUT" >> "$DEBUG_LOG"

# Extract permission details
TOOL_NAME=$(echo "$INPUT" | json_value '.tool_name')
COMMAND=$(echo "$INPUT" | json_value '.tool_input.command')
FILE_PATH=$(echo "$INPUT" | json_value '.tool_input.path')
SESSION_ID=$(echo "$INPUT" | json_value '.session_id')
CWD=$(echo "$INPUT" | json_value '.cwd')

# Extract project name (from cwd or fallback to $PWD)
PROJECT_NAME=""
if [[ -n "$CWD" ]]; then
    PROJECT_NAME=$(basename "$CWD")
elif [[ -n "$PWD" ]]; then
    PROJECT_NAME=$(basename "$PWD")
fi

# Truncate long commands for readability
TRUNCATED_CMD=$(truncate_string "$COMMAND" 100)

# Build tool type label
TOOL_LABEL="[$(echo "$TOOL_NAME" | tr '[:lower:]' '[:upper:]')]"

# Check if this is a bash command permission
if [[ "$TOOL_NAME" == "Bash" ]] && [[ -n "$COMMAND" ]]; then
    # Check if command is in safe whitelist
    if is_safe_command "$COMMAND"; then
        # Debug log
        echo "[barnhk] Auto-approving: $COMMAND" >&2

        # Output approval JSON (correct format for PermissionRequest)
        OUTPUT='{"hookSpecificOutput":{"hookEventName":"PermissionRequest","decision":{"behavior":"allow"}}}'
        echo "$OUTPUT"
        echo "[$(date)] OUTPUT: $OUTPUT" >> "$DEBUG_LOG"

        # Then send notification (non-blocking)
        BODY="$TOOL_LABEL Auto-approved"$'\n'"Cmd: $TRUNCATED_CMD"
        send_notification "claude-auto-permit" "$TITLE_PERMIT" "$BODY" "$PROJECT_NAME"

        exit 0
    fi

    # Try cplit remote approval if enabled
    if is_cplit_enabled; then
        echo "[barnhk] Requesting cplit approval for: $COMMAND" >&2

        DECISION=$(request_cplit_approval "$COMMAND" "${CWD:-$PWD}")

        if [[ "$DECISION" == "approve" ]]; then
            # Output approval JSON
            OUTPUT='{"hookSpecificOutput":{"hookEventName":"PermissionRequest","decision":{"behavior":"allow"}}}'
            echo "$OUTPUT"
            echo "[$(date)] OUTPUT: $OUTPUT (cplit approved)" >> "$DEBUG_LOG"
            exit 0

        elif [[ "$DECISION" == "deny" ]]; then
            # Output denial JSON
            OUTPUT='{"hookSpecificOutput":{"hookEventName":"PermissionRequest","decision":{"behavior":"deny"}}}'
            echo "$OUTPUT"
            echo "[$(date)] OUTPUT: $OUTPUT (cplit denied)" >> "$DEBUG_LOG"
            exit 0
        fi

        # cplit failed or timed out, fall through to local manual approval
        echo "[barnhk] cplit request failed or timed out, falling back to local" >&2
    fi
fi

# Build manual approval notification with details
BODY="$TOOL_LABEL Manual approval needed"
if [[ -n "$COMMAND" ]]; then
    BODY="$BODY"$'\n'"Cmd: $TRUNCATED_CMD"
fi
if [[ -n "$FILE_PATH" ]]; then
    BODY="$BODY"$'\n'"Path: $FILE_PATH"
fi
if [[ -n "$SESSION_ID" ]]; then
    BODY="$BODY"$'\n'"Session: $SESSION_ID"
fi

send_notification "claude-manual-permit" "$TITLE_APPROVAL" "$BODY" "$PROJECT_NAME"
exit 0
