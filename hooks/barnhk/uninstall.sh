#!/bin/bash
# uninstall.sh - Uninstall barnhk hooks

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETTINGS_FILE="$HOME/.claude/settings.json"

echo "Uninstalling barnhk hooks..."

if [[ -f "$SETTINGS_FILE" ]]; then
    # Read existing settings
    SETTINGS=$(cat "$SETTINGS_FILE")

    # Remove barnhk hooks from settings
    SETTINGS=$(echo "$SETTINGS" | jq --arg pre "$SCRIPT_DIR/pre-tool-use.sh" \
        --arg perm "$SCRIPT_DIR/permission-request.sh" \
        --arg task "$SCRIPT_DIR/task-completed.sh" '
        .hooks.PreToolUse = [.hooks.PreToolUse[]? | select(.hooks[0] != $pre)] |
        .hooks.PermissionRequest = [.hooks.PermissionRequest[]? | select(.hooks[0] != $perm)] |
        .hooks.TaskCompleted = [.hooks.TaskCompleted[]? | select(. != $task)]
    ')

    # Write updated settings
    echo "$SETTINGS" | jq '.' > "$SETTINGS_FILE"
    echo "✓ Removed hooks from $SETTINGS_FILE"
else
    echo "Settings file not found: $SETTINGS_FILE"
fi

echo "✓ barnhk hooks uninstalled!"
echo "Note: Config file and scripts are preserved at $SCRIPT_DIR"
