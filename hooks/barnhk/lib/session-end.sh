#!/usr/bin/env bash
# session-end.sh - SessionEnd hook for session end notifications
# Triggered when Claude Code session ends completely

set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Load config
load_config

exit 0
