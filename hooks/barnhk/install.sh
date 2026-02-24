#!/bin/bash
# install.sh - Install barnhk hooks (idempotent)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/lib"
SETTINGS_FILE="$HOME/.claude/settings.json"

echo "Installing barnhk hooks..."

# Check for jq
if ! command -v jq &>/dev/null; then
    echo "Warning: jq is not installed. JSON parsing may not work."
    echo "Install jq with: brew install jq"
fi

# Set config permissions
chmod 600 "$LIB_DIR/barnhk.conf" 2>/dev/null || true

# Make scripts executable
chmod +x "$SCRIPT_DIR"/*.sh
chmod +x "$LIB_DIR"/*.sh

# Ensure settings directory exists
mkdir -p "$(dirname "$SETTINGS_FILE")"

# === Read existing settings ===
if [[ -f "$SETTINGS_FILE" ]]; then
    SETTINGS=$(cat "$SETTINGS_FILE")
else
    SETTINGS="{}"
fi

# === Idempotent: Remove existing barnhk hooks first ===
SETTINGS=$(echo "$SETTINGS" | jq '
    .hooks.PreToolUse = [.hooks.PreToolUse[]? // empty | select(.hooks[0] | test("barnhk") | not)] |
    .hooks.PermissionRequest = [.hooks.PermissionRequest[]? // empty | select(.hooks[0] | test("barnhk") | not)] |
    .hooks.TaskCompleted = [.hooks.TaskCompleted[]? // empty | select(test("barnhk") | not)]
')

# === Add new hooks ===
SETTINGS=$(echo "$SETTINGS" | jq --arg pre "$LIB_DIR/pre-tool-use.sh" \
    --arg perm "$LIB_DIR/permission-request.sh" \
    --arg task "$LIB_DIR/task-completed.sh" '
    .hooks.PreToolUse = (.hooks.PreToolUse // []) + [{"matcher": "Bash", "hooks": [$pre]}] |
    .hooks.PermissionRequest = (.hooks.PermissionRequest // []) + [{"matcher": "bash", "hooks": [$perm]}] |
    .hooks.TaskCompleted = (.hooks.TaskCompleted // []) + [$task]
')

# Write updated settings
echo "$SETTINGS" | jq '.' > "$SETTINGS_FILE"

echo "✓ barnhk hooks installed successfully!"
echo ""
echo "Configuration file: $LIB_DIR/barnhk.conf"
echo "Edit it to set your BARK_SERVER_URL for notifications."
echo ""
echo "Installed hooks:"
echo "  - PreToolUse: $LIB_DIR/pre-tool-use.sh"
echo "  - PermissionRequest: $LIB_DIR/permission-request.sh"
echo "  - TaskCompleted: $LIB_DIR/task-completed.sh"
