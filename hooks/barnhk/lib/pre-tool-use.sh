#!/usr/bin/env bash
# pre-tool-use.sh - PreToolUse hook for dangerous command detection
# Receives JSON via stdin, exits 0 to allow, exit 2 to block

set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Load config
load_config

# Read JSON input
INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | json_value '.tool_name')
COMMAND=$(echo "$INPUT" | json_value '.tool_input.command')

# Only check Bash tool commands
if [[ "$TOOL_NAME" != "Bash" ]] || [[ -z "$COMMAND" ]]; then
    exit 0
fi

# Check danger level
DANGER_LEVEL=$(check_danger_level "$COMMAND")

case "$DANGER_LEVEL" in
    critical)
        REASON="Critical dangerous command detected: $COMMAND"
        echo "BLOCKED: $REASON" >&2
        send_bark_notification "claude-danger" "$TITLE_DANGER" "Blocked: $COMMAND"
        echo "{\"hookSpecificOutput\":{\"permissionDecision\":\"deny\",\"denyReason\":\"$REASON\"}}"
        exit 2
        ;;
    high)
        REASON="High-risk command detected: $COMMAND"
        echo "BLOCKED: $REASON" >&2
        send_bark_notification "claude-danger" "$TITLE_DANGER" "Blocked: $COMMAND"
        echo "{\"hookSpecificOutput\":{\"permissionDecision\":\"deny\",\"denyReason\":\"$REASON\"}}"
        exit 2
        ;;
    medium|safe)
        # Allow without blocking
        exit 0
        ;;
esac

exit 0
