#!/bin/bash
# ==============================================================================
# Panck - Claude Code Skill Installer
# ==============================================================================

set -e

SKILL_NAME="panck"
SKILL_DIR="$(cd "$(dirname "$0")" && pwd)/${SKILL_NAME}-plugin"
TARGET_DIR="${HOME}/.claude/skills/${SKILL_NAME}"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}                    Panck - Service Scaffold Generator               ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo

# Check if skill directory exists
if [[ ! -d "$SKILL_DIR" ]]; then
    echo -e "${RED}✗ Skill directory not found: ${SKILL_DIR}${NC}"
    exit 1
fi

# Create target directory
mkdir -p "$(dirname "$TARGET_DIR")"

# Remove existing installation
if [[ -d "$TARGET_DIR" ]]; then
    echo -e "${CYAN}→ Removing existing installation...${NC}"
    rm -rf "$TARGET_DIR"
fi

# Copy skill files
echo -e "${CYAN}→ Installing to ${TARGET_DIR}...${NC}"
cp -r "$SKILL_DIR" "$TARGET_DIR"

# Verify installation
if [[ -f "${TARGET_DIR}/SKILL.md" ]]; then
    echo
    echo -e "${GREEN}✓ Installation successful!${NC}"
    echo
    echo "Usage:"
    echo "  /panck usersrv"
    echo "  /panck notifysrv"
    echo
    echo "Or simply say:"
    echo "  创建一个通知服务 notifysrv"
    echo
else
    echo -e "${RED}✗ Installation failed${NC}"
    exit 1
fi
