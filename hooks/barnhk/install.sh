#!/usr/bin/env bash
# install.sh - Install barnhk hooks to global directory (idempotent)

set -e

# Minimum bash version required (3.0+ for BASH_SOURCE)
MIN_BASH_MAJOR=3

# Check bash version
if [[ "${BASH_VERSINFO[0]}" -lt "$MIN_BASH_MAJOR" ]]; then
    echo "Error: Bash version ${BASH_VERSINFO[0]}.${BASH_VERSINFO[1]} is too old."
    echo "barnhk requires Bash $MIN_BASH_MAJOR.0 or later."
    echo "Current bash: $BASH_VERSION"
    exit 1
fi

# Verbose mode
VERBOSE="${VERBOSE:-false}"
debug() {
    if [[ "$VERBOSE" == "true" ]]; then
        echo "[DEBUG] $*"
    fi
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/lib"
GLOBAL_DIR="$HOME/.claude/hooks/barnhk"
GLOBAL_LIB="$GLOBAL_DIR/lib"
SETTINGS_FILE="$HOME/.claude/settings.json"

# Detect OS
OS_TYPE=$(uname -s)

echo "Installing barnhk hooks..."
debug "OS: $OS_TYPE"
debug "Bash version: $BASH_VERSION"
debug "Script directory: $SCRIPT_DIR"

# Check for jq (required)
if ! command -v jq &>/dev/null; then
    echo "Error: jq is not installed. jq is required for JSON parsing."
    echo ""
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
            elif command -v pacman &>/dev/null; then
                echo "Install jq with: sudo pacman -S jq"
            elif command -v zypper &>/dev/null; then
                echo "Install jq with: sudo zypper install jq"
            else
                echo "Install jq using your package manager"
            fi
            ;;
        *)
            echo "Install jq using your package manager"
            ;;
    esac
    exit 1
fi

# Error handler for better debugging
trap 'echo "Error: Installation failed at line $LINENO"; echo "Run with VERBOSE=true for more details"; exit 1' ERR

# Make source scripts executable
chmod +x "$SCRIPT_DIR"/*.sh
chmod +x "$LIB_DIR"/*.sh

# === Create global directory structure ===
mkdir -p "$GLOBAL_LIB"

# === Copy files to global directory (preserve existing config) ===
for file in "$LIB_DIR"/*.sh; do
    cp "$file" "$GLOBAL_LIB/"
done

# Copy config (always update to latest template)
cp "$LIB_DIR/barnhk.conf" "$GLOBAL_LIB/"
chmod 600 "$GLOBAL_LIB/barnhk.conf"

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
    .hooks.SessionEnd = [.hooks.SessionEnd[]? // empty | select(.hooks[]?.command? | test("barnhk") | not)] |
    .hooks.TeammateIdle = [.hooks.TeammateIdle[]? // empty | select(.hooks[]?.command? | test("barnhk") | not)] |
    .hooks.Notification = [.hooks.Notification[]? // empty | select(.hooks[]?.command? | test("barnhk") | not)]
')

# === Add new hooks with correct format ===
# Note: matcher is a string regex for PreToolUse/PermissionRequest
# TaskCompleted/Stop/SessionEnd/TeammateIdle/Notification do not support matchers
SETTINGS=$(echo "$SETTINGS" | jq --arg pre "$GLOBAL_LIB/pre-tool-use.sh" \
    --arg perm "$GLOBAL_LIB/permission-request.sh" \
    --arg task "$GLOBAL_LIB/task-completed.sh" \
    --arg stop "$GLOBAL_LIB/stop.sh" \
    --arg session "$GLOBAL_LIB/session-end.sh" \
    --arg idle "$GLOBAL_LIB/teammate-idle.sh" \
    --arg notif "$GLOBAL_LIB/notification.sh" '
    .hooks.PreToolUse = (.hooks.PreToolUse // []) + [{"matcher": "Bash", "hooks": [{"type": "command", "command": $pre}]}] |
    .hooks.PermissionRequest = (.hooks.PermissionRequest // []) + [{"matcher": "Bash", "hooks": [{"type": "command", "command": $perm}]}] |
    .hooks.TaskCompleted = (.hooks.TaskCompleted // []) + [{"hooks": [{"type": "command", "command": $task}]}] |
    .hooks.Stop = (.hooks.Stop // []) + [{"hooks": [{"type": "command", "command": $stop}]}] |
    .hooks.SessionEnd = (.hooks.SessionEnd // []) + [{"hooks": [{"type": "command", "command": $session}]}] |
    .hooks.TeammateIdle = (.hooks.TeammateIdle // []) + [{"hooks": [{"type": "command", "command": $idle}]}] |
    .hooks.Notification = (.hooks.Notification // []) + [{"hooks": [{"type": "command", "command": $notif}]}]
')

# Write updated settings
echo "$SETTINGS" | jq '.' > "$SETTINGS_FILE"

echo "✓ barnhk hooks installed successfully!"
echo ""
echo "Global installation: $GLOBAL_DIR"
echo "Configuration file: $GLOBAL_LIB/barnhk.conf"
echo ""
echo "⚠️  Config has been updated. Please check your settings:"
echo "   cat $GLOBAL_LIB/barnhk.conf"
echo ""
echo "Installed hooks:"
echo "  - PreToolUse: $GLOBAL_LIB/pre-tool-use.sh"
echo "  - PermissionRequest: $GLOBAL_LIB/permission-request.sh"
echo "  - TaskCompleted: $GLOBAL_LIB/task-completed.sh"
echo "  - Stop: $GLOBAL_LIB/stop.sh"
echo "  - SessionEnd: $GLOBAL_LIB/session-end.sh"
echo "  - TeammateIdle: $GLOBAL_LIB/teammate-idle.sh"
echo "  - Notification: $GLOBAL_LIB/notification.sh"
