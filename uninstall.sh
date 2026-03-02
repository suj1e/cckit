#!/bin/bash
# ==============================================================================
# cckit - Claude Code Kit Uninstaller
# Uninstalls cckit plugins
# ==============================================================================

set -e

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

uninstall_plugin() {
  local name="$1"

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
