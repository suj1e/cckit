#!/bin/bash
# uninstall.sh - Uninstall barnhk hooks

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETTINGS_FILE="$HOME/.claude/settings.json"

echo "Uninstalling barnhk hooks..."

if [[ -f "$SETTINGS_FILE" ]]; then
    # Read existing settings
    SETTINGS=$(cat "$SETTINGS_FILE")

    # Remove any hooks containing "barnhk" in their path (pattern matching)
    SETTINGS=$(echo "$SETTINGS" | jq '
        .hooks.PreToolUse = [.hooks.PreToolUse[]? | select(.hooks[0] | test("barnhk") | not)] |
        .hooks.PermissionRequest = [.hooks.PermissionRequest[]? | select(.hooks[0] | test("barnhk") | not)] |
        .hooks.TaskCompleted = [.hooks.TaskCompleted[]? | select(test("barnhk") | not)]
    ' 2>/dev/null || echo "$SETTINGS")

    # Write updated settings
    echo "$SETTINGS" | jq '.' > "$SETTINGS_FILE"
    echo "✓ Removed hooks from $SETTINGS_FILE"
else
    echo "Settings file not found: $SETTINGS_FILE"
fi

echo "✓ barnhk hooks uninstalled!"
echo "Note: Config file and scripts are preserved at $SCRIPT_DIR"
