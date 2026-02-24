#!/bin/bash
# ==============================================================================
# Panck - Claude Code Skill Uninstaller
# ==============================================================================

set -e

SKILL_NAME="panck"
TARGET_DIR="${HOME}/.claude/skills/${SKILL_NAME}"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}                    Panck - Uninstaller                              ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo

if [[ -d "$TARGET_DIR" ]]; then
    echo -e "${CYAN}→ Removing ${TARGET_DIR}...${NC}"
    rm -rf "$TARGET_DIR"
    echo -e "${GREEN}✓ Uninstallation successful${NC}"
else
    echo -e "${CYAN}→ Panck is not installed${NC}"
fi
