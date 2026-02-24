#!/bin/bash
# install.sh - Install barnhk hooks to global directory (idempotent)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/lib"
GLOBAL_DIR="$HOME/.claude/hooks/barnhk"
GLOBAL_LIB="$GLOBAL_DIR/lib"
SETTINGS_FILE="$HOME/.claude/settings.json"

echo "Installing barnhk hooks..."

# Detect OS
OS_TYPE=$(uname -s)

# Check for jq
if ! command -v jq &>/dev/null; then
    echo "Warning: jq is not installed. JSON parsing may not work."
    case "$OS_TYPE" in
        Darwin)
            echo "Install jq with: brew install jq"
            ;;
        Linux)
            if command -v apt &>/dev/null; then
                echo "Install jq with: sudo apt install jq"
            elif command -v yum &>/dev/null; then
                echo "Install jq with: sudo yum install jq"
            elif command -v dnf &>/dev/null; then
                echo "Install jq with: sudo dnf install jq"
            else
                echo "Install jq using your package manager"
            fi
            ;;
        *)
            echo "Install jq using your package manager"
            ;;
    esac
fi

# Make source scripts executable
chmod +x "$SCRIPT_DIR"/*.sh
chmod +x "$LIB_DIR"/*.sh

# === Create global directory structure ===
mkdir -p "$GLOBAL_LIB"

# === Copy files to global directory (preserve existing config) ===
for file in "$LIB_DIR"/*.sh; do
    cp "$file" "$GLOBAL_LIB/"
done

# Copy config only if it doesn't exist
if [[ ! -f "$GLOBAL_LIB/barnhk.conf" ]]; then
    cp "$LIB_DIR/barnhk.conf" "$GLOBAL_LIB/"
    chmod 600 "$GLOBAL_LIB/barnhk.conf"
fi

# === Ensure settings directory exists ===
mkdir -p "$(dirname "$SETTINGS_FILE")"

# === Read existing settings ===
if [[ -f "$SETTINGS_FILE" ]]; then
    SETTINGS=$(cat "$SETTINGS_FILE")
else
    SETTINGS="{}"
fi

# === Idempotent: Remove existing barnhk hooks first ===
SETTINGS=$(echo "$SETTINGS" | jq '
    .hooks.PreToolUse = [.hooks.PreToolUse[]? // empty | select(.hooks[]?.command? | test("barnhk") | not)] |
    .hooks.PermissionRequest = [.hooks.PermissionRequest[]? // empty | select(.hooks[]?.command? | test("barnhk") | not)] |
    .hooks.TaskCompleted = [.hooks.TaskCompleted[]? // empty | select(.hooks[]?.command? | test("barnhk") | not)] |
    .hooks.Stop = [.hooks.Stop[]? // empty | select(.hooks[]?.command? | test("barnhk") | not)] |
    .hooks.TeammateIdle = [.hooks.TeammateIdle[]? // empty | select(.hooks[]?.command? | test("barnhk") | not)]
')

# === Add new hooks with correct format ===
# Note: matcher is a string regex for PreToolUse/PermissionRequest
# TaskCompleted/Stop/TeammateIdle do not support matchers
SETTINGS=$(echo "$SETTINGS" | jq --arg pre "$GLOBAL_LIB/pre-tool-use.sh" \
    --arg perm "$GLOBAL_LIB/permission-request.sh" \
    --arg task "$GLOBAL_LIB/task-completed.sh" \
    --arg stop "$GLOBAL_LIB/stop.sh" \
    --arg idle "$GLOBAL_LIB/teammate-idle.sh" '
    .hooks.PreToolUse = (.hooks.PreToolUse // []) + [{"matcher": "Bash", "hooks": [{"type": "command", "command": $pre}]}] |
    .hooks.PermissionRequest = (.hooks.PermissionRequest // []) + [{"matcher": "Bash", "hooks": [{"type": "command", "command": $perm}]}] |
    .hooks.TaskCompleted = (.hooks.TaskCompleted // []) + [{"hooks": [{"type": "command", "command": $task}]}] |
    .hooks.Stop = (.hooks.Stop // []) + [{"hooks": [{"type": "command", "command": $stop}]}] |
    .hooks.TeammateIdle = (.hooks.TeammateIdle // []) + [{"hooks": [{"type": "command", "command": $idle}]}]
')

# Write updated settings
echo "$SETTINGS" | jq '.' > "$SETTINGS_FILE"

echo "✓ barnhk hooks installed successfully!"
echo ""
echo "Global installation: $GLOBAL_DIR"
echo "Configuration file: $GLOBAL_LIB/barnhk.conf"
echo "Edit it to set your BARK_SERVER_URL for notifications."
echo ""
echo "Installed hooks:"
echo "  - PreToolUse: $GLOBAL_LIB/pre-tool-use.sh"
echo "  - PermissionRequest: $GLOBAL_LIB/permission-request.sh"
echo "  - TaskCompleted: $GLOBAL_LIB/task-completed.sh"
echo "  - Stop: $GLOBAL_LIB/stop.sh"
echo "  - TeammateIdle: $GLOBAL_LIB/teammate-idle.sh"
