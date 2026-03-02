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

install_plugin() {
  local name="$1"
  echo -e "${CYAN}→ Installing ${name}...${NC}"
  claude plugin install "${name}@cckit" --scope user
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
