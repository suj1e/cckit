#!/usr/bin/env bash
# teammate-idle.sh - TeammateIdle hook for teammate idle notifications
# Receives JSON via stdin

set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Load config
load_config

exit 0
