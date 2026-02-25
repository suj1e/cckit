#!/bin/bash
# ==============================================================================
# cckit - Claude Code Kit Uninstaller
# Uninstalls cckit plugins and removes hooks from settings
# ==============================================================================

set -e

SETTINGS_FILE="$HOME/.claude/settings.json"

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

# Available plugins
PLUGINS="panck barnhk"

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}                   cckit - Claude Code Kit Uninstaller              ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo

# Remove hooks from settings.json
remove_hooks() {
  local name="$1"

  if [[ ! -f "$SETTINGS_FILE" ]]; then
    return 0
  fi

  echo -e "${CYAN}→ Removing hooks for ${name}...${NC}"

  local settings
  settings=$(cat "$SETTINGS_FILE" | jq '
    .hooks.PreToolUse = [.hooks.PreToolUse[]? // empty | select(.hooks[]?.command? | test("cckit/'"$name"'") | not)] |
    .hooks.PermissionRequest = [.hooks.PermissionRequest[]? // empty | select(.hooks[]?.command? | test("cckit/'"$name"'") | not)] |
    .hooks.TaskCompleted = [.hooks.TaskCompleted[]? // empty | select(.hooks[]?.command? | test("cckit/'"$name"'") | not)] |
    .hooks.Stop = [.hooks.Stop[]? // empty | select(.hooks[]?.command? | test("cckit/'"$name"'") | not)] |
    .hooks.SessionEnd = [.hooks.SessionEnd[]? // empty | select(.hooks[]?.command? | test("cckit/'"$name"'") | not)] |
    .hooks.TeammateIdle = [.hooks.TeammateIdle[]? // empty | select(.hooks[]?.command? | test("cckit/'"$name"'") | not)] |
    .hooks.Notification = [.hooks.Notification[]? // empty | select(.hooks[]?.command? | test("cckit/'"$name"'") | not)]
  ')

  echo "$settings" | jq '.' > "$SETTINGS_FILE"
}

uninstall_plugin() {
  local name="$1"

  # Remove hooks first
  remove_hooks "$name"

  echo -e "${CYAN}→ Uninstalling ${name}...${NC}"
  if claude plugin uninstall "${name}@cckit" --scope user 2>/dev/null; then
    echo -e "${GREEN}✓ ${name} uninstalled${NC}"
  else
    echo -e "${RED}✗ ${name} not installed or already removed${NC}"
  fi
}

# If specific plugin(s) specified, uninstall only those
if [[ $# -gt 0 ]]; then
  for plugin_name in "$@"; do
    case "$plugin_name" in
      panck|barnhk)
        uninstall_plugin "$plugin_name"
        ;;
      *)
        echo "✗ Unknown plugin: $plugin_name"
        echo "Available plugins: panck, barnhk"
        exit 1
        ;;
    esac
  done
else
  # Uninstall all plugins
  for plugin_name in $PLUGINS; do
    uninstall_plugin "$plugin_name"
  done
fi

echo
echo -e "${GREEN}✓ Uninstallation complete!${NC}"
