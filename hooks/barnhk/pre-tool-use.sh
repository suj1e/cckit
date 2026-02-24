#!/bin/bash
# pre-tool-use.sh - PreToolUse hook for dangerous command detection
# Receives JSON via stdin, exits 0 to allow, non-zero to block

set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Load config
load_config

# Read JSON input
INPUT=$(cat)
TOOL=$(echo "$INPUT" | json_value '.tool')
COMMAND=$(echo "$INPUT" | json_value '.input.command')

# Only check Bash tool commands
if [[ "$TOOL" != "Bash" ]] || [[ -z "$COMMAND" ]]; then
    exit 0
fi

# Check danger level
DANGER_LEVEL=$(check_danger_level "$COMMAND")

case "$DANGER_LEVEL" in
    critical)
        echo "BLOCKED: Critical dangerous command detected: $COMMAND" >&2
        send_bark_notification "claude-danger" "$TITLE_DANGER" "Blocked: $COMMAND"
        exit 1
        ;;
    high)
        echo "BLOCKED: High-risk command detected: $COMMAND" >&2
        send_bark_notification "claude-danger" "$TITLE_DANGER" "Blocked: $COMMAND"
        exit 1
        ;;
    medium|safe)
        # Allow without blocking
        exit 0
        ;;
esac

exit 0
