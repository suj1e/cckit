#!/bin/bash
# install.sh - Install barnhk hooks

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETTINGS_FILE="$HOME/.claude/settings.json"

echo "Installing barnhk hooks..."

# Check for jq
if ! command -v jq &>/dev/null; then
    echo "Warning: jq is not installed. JSON parsing may not work."
    echo "Install jq with: brew install jq"
fi

# Create config file if not exists
if [[ ! -f "$SCRIPT_DIR/barnhk.conf" ]]; then
    cp "$SCRIPT_DIR/barnhk.conf.example" "$SCRIPT_DIR/barnhk.conf" 2>/dev/null || true
fi

# Set config permissions
chmod 600 "$SCRIPT_DIR/barnhk.conf" 2>/dev/null || true

# Make scripts executable
chmod +x "$SCRIPT_DIR"/*.sh

# Ensure settings directory exists
mkdir -p "$(dirname "$SETTINGS_FILE")"

# Update settings.json
if [[ -f "$SETTINGS_FILE" ]]; then
    # Read existing settings
    SETTINGS=$(cat "$SETTINGS_FILE")
else
    SETTINGS="{}"
fi

# Add hooks configuration
SETTINGS=$(echo "$SETTINGS" | jq --arg pre "$SCRIPT_DIR/pre-tool-use.sh" \
    --arg perm "$SCRIPT_DIR/permission-request.sh" \
    --arg task "$SCRIPT_DIR/task-completed.sh" '
    .hooks.PreToolUse += [{"matcher": "Bash", "hooks": [$pre]}] |
    .hooks.PermissionRequest += [{"matcher": "bash", "hooks": [$perm]}] |
    .hooks.TaskCompleted += [$task]
')

# Write updated settings
echo "$SETTINGS" | jq '.' > "$SETTINGS_FILE"

echo "✓ barnhk hooks installed successfully!"
echo ""
echo "Configuration file: $SCRIPT_DIR/barnhk.conf"
echo "Edit it to set your BARK_SERVER_URL for notifications."
echo ""
echo "Installed hooks:"
echo "  - PreToolUse: $SCRIPT_DIR/pre-tool-use.sh"
echo "  - PermissionRequest: $SCRIPT_DIR/permission-request.sh"
echo "  - TaskCompleted: $SCRIPT_DIR/task-completed.sh"
