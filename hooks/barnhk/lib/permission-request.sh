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

# Debug: log input (only when enabled)
DEBUG_LOG="/tmp/barnhk-permission-debug.log"
if [[ "${DEBUG_ENABLED:-false}" == "true" ]]; then
    echo "[$(date)] INPUT: $INPUT" >> "$DEBUG_LOG"
fi

# Extract permission details
TOOL_NAME=$(echo "$INPUT" | json_value '.tool_name')
COMMAND=$(echo "$INPUT" | json_value '.tool_input.command')
FILE_PATH=$(echo "$INPUT" | json_value '.tool_input.path')
CWD=$(echo "$INPUT" | json_value '.cwd')

# Auto-approve Edit/Write for files within project directory
if [[ "$TOOL_NAME" == "Edit" ]] || [[ "$TOOL_NAME" == "Write" ]]; then
    FILE_PATH=$(echo "$INPUT" | json_value '.tool_input.file_path // .tool_input.path')
    if [[ -n "$FILE_PATH" ]] && [[ -n "$CWD" ]]; then
        if [[ "$FILE_PATH" == "$CWD"* ]]; then
            echo "[barnhk] Auto-approving: $TOOL_NAME $FILE_PATH" >&2
            OUTPUT='{"hookSpecificOutput":{"hookEventName":"PermissionRequest","decision":{"behavior":"allow"}}}'
            echo "$OUTPUT"
            exit 0
        fi
    fi
fi

# Check if this is a bash command permission
if [[ "$TOOL_NAME" == "Bash" ]] && [[ -n "$COMMAND" ]]; then
    # Check if command is in safe whitelist (pass CWD for project directory check)
    if is_safe_command "$COMMAND" "$CWD"; then
        # Debug log
        echo "[barnhk] Auto-approving: $COMMAND" >&2

        # Output approval JSON (correct format for PermissionRequest)
        OUTPUT='{"hookSpecificOutput":{"hookEventName":"PermissionRequest","decision":{"behavior":"allow"}}}'
        echo "$OUTPUT"
        [[ "${DEBUG_ENABLED:-false}" == "true" ]] && echo "[$(date)] OUTPUT: $OUTPUT" >> "$DEBUG_LOG"

        exit 0
    fi
fi

exit 0
