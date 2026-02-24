#!/bin/bash
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

# Check if this is a bash command permission
if [[ "$PERMISSION_NAME" == "bash" ]] && [[ -n "$COMMAND" ]]; then
    # Check if command is in safe whitelist
    if is_safe_command "$COMMAND"; then
        # Send notification (optional)
        send_bark_notification "claude-permit" "$TITLE_PERMIT" "Auto-approved: $COMMAND"

        # Output approval JSON
        echo '{"decision": "allow"}'
        exit 0
    fi
fi

# For non-whitelisted commands, let user decide (no output = ask user)
exit 0
