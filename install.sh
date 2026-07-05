#!/bin/bash
# ==============================================================================
# cckit - Claude Code Kit Installer
# Installs cckit plugins via marketplace
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

# Available plugins
PLUGINS="jbrick barnhk just-task"

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}                    cckit - Claude Code Kit Installer               ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo

# Ensure marketplace is added
ensure_marketplace() {
  if jq -e '.cckit' ~/.claude/plugins/known_marketplaces.json >/dev/null 2>&1; then
    return 0
  fi

  echo -e "${CYAN}→ Adding cckit marketplace...${NC}"
  if ! claude plugin marketplace add "$SCRIPT_DIR"; then
    echo -e "${RED}✗ Failed to add cckit marketplace. Check if .claude-plugin/marketplace.json exists.${NC}"
    exit 1
  fi
}

install_plugin() {
  local name="$1"
  echo -e "${CYAN}→ Installing ${name}...${NC}"
  if claude plugin install "${name}@cckit" --scope user; then
    echo -e "${GREEN}✓ ${name} installed${NC}"

    # Platform adaptation: source plugin.json uses .sh (canonical).
    # Installed copy should already be .sh on Unix, but normalize defensively
    # in case the cache retains a stale .ps1 from a previous install.
    adapt_platform "$name"
  else
    echo -e "${RED}✗ Failed to install ${name}${NC}"
    return 1
  fi
}

# Convert hook script paths in installed plugin.json to match the current OS.
# Source-of-truth plugin.json in the repo uses .sh; on Windows, .sh → .ps1.
adapt_platform() {
  local name="$1"
  local plugin_json
  plugin_json="$HOME/.claude/plugins/cache/cckit/${name}/"*/.claude-plugin/plugin.json
  if [[ ! -f "$plugin_json" ]]; then
    return 0
  fi
  if grep -q '\.ps1' "$plugin_json" 2>/dev/null; then
    sed -i '' 's/\.ps1/.sh/g' "$plugin_json"
    echo -e "${GREEN}  → Platform adaptation: .ps1 → .sh${NC}"
  fi
}

# Ensure marketplace exists
ensure_marketplace

# If specific plugin(s) specified, install only those
if [[ $# -gt 0 ]]; then
  for plugin_name in "$@"; do
    case "$plugin_name" in
      jbrick|barnhk|just-task)
        install_plugin "$plugin_name"
        ;;
      *)
        echo -e "${RED}✗ Unknown plugin: $plugin_name${NC}"
        echo "Available plugins: jbrick, barnhk, just-task"
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
echo "  - jbrick:            /jbrick <service-name>"
echo "  - barnhk:            Safety & notification hooks"
echo "  - just-task:         /just-task run|restart|build|test|stop"
echo
echo "To uninstall, run: ./uninstall.sh [plugin-name]"
