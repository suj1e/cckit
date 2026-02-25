#!/usr/bin/env bash
# uninstall.sh - Uninstall barnhk hooks

GLOBAL_DIR="$HOME/.claude/hooks/barnhk"
SETTINGS_FILE="$HOME/.claude/settings.json"

echo "Uninstalling barnhk hooks..."

if [[ -f "$SETTINGS_FILE" ]]; then
    # Read existing settings
    SETTINGS=$(cat "$SETTINGS_FILE")

    # Remove any hooks containing "barnhk" in their command path
    SETTINGS=$(echo "$SETTINGS" | jq '
        .hooks.PreToolUse = [.hooks.PreToolUse[]? // empty | select(.hooks[]?.command? | test("barnhk") | not)] |
        .hooks.PermissionRequest = [.hooks.PermissionRequest[]? // empty | select(.hooks[]?.command? | test("barnhk") | not)] |
        .hooks.TaskCompleted = [.hooks.TaskCompleted[]? // empty | select(.hooks[]?.command? | test("barnhk") | not)] |
        .hooks.Stop = [.hooks.Stop[]? // empty | select(.hooks[]?.command? | test("barnhk") | not)] |
        .hooks.SessionEnd = [.hooks.SessionEnd[]? // empty | select(.hooks[]?.command? | test("barnhk") | not)] |
        .hooks.TeammateIdle = [.hooks.TeammateIdle[]? // empty | select(.hooks[]?.command? | test("barnhk") | not)] |
        .hooks.Notification = [.hooks.Notification[]? // empty | select(.hooks[]?.command? | test("barnhk") | not)]
    ')

    # Write updated settings
    echo "$SETTINGS" | jq '.' > "$SETTINGS_FILE"
    echo "✓ Removed hooks from settings.json"
fi

# Remove global installation directory
if [[ -d "$GLOBAL_DIR" ]]; then
    rm -rf "$GLOBAL_DIR"
    echo "✓ Removed $GLOBAL_DIR"
fi

echo "✓ barnhk hooks uninstalled!"
