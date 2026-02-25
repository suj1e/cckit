#!/bin/bash
# ==============================================================================
# cckit - Claude Code Kit Installer
# Installs cckit plugins via marketplace
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SETTINGS_FILE="$HOME/.claude/settings.json"

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

# Available plugins
PLUGINS="panck barnhk"

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}                    cckit - Claude Code Kit Installer               ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo

# Ensure marketplace is added
ensure_marketplace() {
  if ! cat ~/.claude/plugins/known_marketplaces.json 2>/dev/null | jq -e '.cckit' > /dev/null 2>&1; then
    echo -e "${CYAN}→ Adding cckit marketplace...${NC}"
    claude plugin marketplace add "$SCRIPT_DIR"
  fi
}

# Get plugin install path
get_install_path() {
  local name="$1"
  cat ~/.claude/plugins/installed_plugins.json 2>/dev/null | jq -r ".plugins[\"${name}@cckit\"][0].installPath // empty"
}

# Merge hooks from plugin to settings.json
merge_hooks() {
  local name="$1"
  local install_path="$2"
  local plugin_json="$install_path/.claude-plugin/plugin.json"

  if [[ ! -f "$plugin_json" ]]; then
    return 0
  fi

  # Check if plugin has hooks
  local has_hooks
  has_hooks=$(cat "$plugin_json" | jq -e '.hooks != null' 2>/dev/null || echo "false")

  if [[ "$has_hooks" != "true" ]]; then
    return 0
  fi

  echo -e "${CYAN}→ Registering hooks for ${name}...${NC}"

  # Ensure settings file exists
  mkdir -p "$(dirname "$SETTINGS_FILE")"
  if [[ ! -f "$SETTINGS_FILE" ]]; then
    echo '{}' > "$SETTINGS_FILE"
  fi

  # Remove existing hooks for this plugin first
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

  # Replace ${CLAUDE_PLUGIN_ROOT} with actual path and extract hooks
  local new_hooks
  new_hooks=$(cat "$plugin_json" | sed "s|\${CLAUDE_PLUGIN_ROOT}|$install_path|g" | jq '.hooks')

  if [[ -n "$new_hooks" ]] && [[ "$new_hooks" != "null" ]]; then
    # Merge hooks into settings
    settings=$(echo "$settings" | jq --argjson new "$new_hooks" '
      .hooks.PreToolUse = (.hooks.PreToolUse // []) + ($new.PreToolUse // []) |
      .hooks.PermissionRequest = (.hooks.PermissionRequest // []) + ($new.PermissionRequest // []) |
      .hooks.TaskCompleted = (.hooks.TaskCompleted // []) + ($new.TaskCompleted // []) |
      .hooks.Stop = (.hooks.Stop // []) + ($new.Stop // []) |
      .hooks.SessionEnd = (.hooks.SessionEnd // []) + ($new.SessionEnd // []) |
      .hooks.TeammateIdle = (.hooks.TeammateIdle // []) + ($new.TeammateIdle // []) |
      .hooks.Notification = (.hooks.Notification // []) + ($new.Notification // [])
    ')
    echo "$settings" | jq '.' > "$SETTINGS_FILE"
  fi
}

install_plugin() {
  local name="$1"
  echo -e "${CYAN}→ Installing ${name}...${NC}"
  claude plugin install "${name}@cckit" --scope user

  # Get install path and merge hooks
  local install_path
  install_path=$(get_install_path "$name")

  if [[ -n "$install_path" ]]; then
    merge_hooks "$name" "$install_path"
  fi

  echo -e "${GREEN}✓ ${name} installed${NC}"
}

# Ensure marketplace exists
ensure_marketplace

# If specific plugin(s) specified, install only those
if [[ $# -gt 0 ]]; then
  for plugin_name in "$@"; do
    case "$plugin_name" in
      panck|barnhk)
        install_plugin "$plugin_name"
        ;;
      *)
        echo "✗ Unknown plugin: $plugin_name"
        echo "Available plugins: panck, barnhk"
        exit 1
        ;;
    esac
  done
else
  # Install all plugins
  for plugin_name in $PLUGINS; do
    install_plugin "$plugin_name"
  done
fi

echo
echo -e "${GREEN}✓ Installation complete!${NC}"
echo
echo "Installed plugins:"
echo "  - panck:   /panck <service-name>"
echo "  - barnhk:  Safety & notification hooks"
echo
echo "To uninstall, run: ./uninstall.sh [plugin-name]"
