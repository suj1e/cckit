#!/usr/bin/env bash
# common.sh - Shared functions for barnhk hooks

# Get the directory where this script is located
BARNHK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BARNHK_CONF="$BARNHK_DIR/barnhk.conf"

# Load configuration
load_config() {
    if [[ -f "$BARNHK_CONF" ]]; then
        source "$BARNHK_CONF"
    fi
}

# Parse JSON from stdin using jq
# Usage: json_value <key>
json_value() {
    local key="$1"
    jq -r "$key // empty" 2>/dev/null
}

# Send Bark notification (optional, silent failure)
# Usage: send_bark_notification <group> <title> <body>
send_bark_notification() {
    local group="$1"
    local title="$2"
    local body="$3"

    # Skip if not configured
    if [[ -z "$BARK_SERVER_URL" ]]; then
        return 0
    fi

    # Validate URL format
    if [[ ! "$BARK_SERVER_URL" =~ ^https?:// ]]; then
        return 0
    fi

    # Determine sound based on group
    local sound=""
    case "$group" in
        claude-danger)
            sound="alarm.caf"
            ;;
        claude-permit)
            sound="bell.caf"
            ;;
        claude-done)
            sound="glass.caf"
            ;;
    esac

    # URL encode title and body
    local encoded_title=$(printf '%s' "$title" | jq -sRr @uri)
    local encoded_body=$(printf '%s' "$body" | jq -sRr @uri)
    local encoded_group=$(printf '%s' "$group" | jq -sRr @uri)

    # Build URL
    local url="${BARK_SERVER_URL%/}/${encoded_title}/${encoded_body}?group=${encoded_group}"
    if [[ -n "$sound" ]]; then
        url="${url}&sound=${sound}"
    fi

    # Send notification (silent failure)
    curl -s -m 3 "$url" >/dev/null 2>&1 || true
}

# Check if command matches safe whitelist
# Usage: is_safe_command <command>
is_safe_command() {
    local cmd="$1"

    # Git commands
    if [[ "$cmd" =~ ^git[[:space:]]+(status|log|diff|add|commit|push|pull|checkout|merge|rebase|branch|fetch|stash|reset|restore|switch|show) ]]; then
        return 0
    fi

    # Package managers
    if [[ "$cmd" =~ ^(npm|pnpm|yarn|pip)[[:space:]]+(install|run|test|build|start|dev|ci) ]]; then
        return 0
    fi

    # Build tools
    if [[ "$cmd" =~ ^(gradle|mvn|cargo)[[:space:]] ]]; then
        return 0
    fi

    # File read operations
    if [[ "$cmd" =~ ^(ls|cat|grep|find|head|tail|wc|sort|uniq|cut|awk|sed)[[:space:]] ]]; then
        return 0
    fi
    if [[ "$cmd" =~ ^(ls|cat|grep|find|head|tail)$ ]]; then
        return 0
    fi

    # Custom whitelist from config
    if [[ -n "$SAFE_COMMANDS" ]]; then
        local pattern
        for pattern in $SAFE_COMMANDS; do
            if [[ "$cmd" =~ $pattern ]]; then
                return 0
            fi
        done
    fi

    return 1
}

# Check command danger level
# Returns: 0=safe, 1=medium, 2=high, 3=critical
check_danger_level() {
    local cmd="$1"

    # Critical level - always block
    if [[ "$cmd" =~ rm[[:space:]]+-rf[[:space:]]+(/|/\*) ]]; then
        echo "critical"
        return
    fi
    if [[ "$cmd" =~ dd[[:space:]].*of=/dev/ ]]; then
        echo "critical"
        return
    fi
    if [[ "$cmd" =~ mkfs[[:space:]] ]]; then
        echo "critical"
        return
    fi

    # High level - block
    if [[ "$cmd" =~ ^sudo[[:space:]] ]]; then
        echo "high"
        return
    fi
    if [[ "$cmd" =~ (curl|wget).*\|[[:space:]]*(bash|sh) ]]; then
        echo "high"
        return
    fi
    if [[ "$cmd" =~ chmod[[:space:]]+-R[[:space:]]+777 ]]; then
        echo "high"
        return
    fi
    if [[ "$cmd" =~ chmod[[:space:]]+777[[:space:]]+/ ]]; then
        echo "high"
        return
    fi

    # Medium level - allow (no action needed)
    if [[ "$cmd" =~ (nc|netcat)[[:space:]]+-l ]]; then
        echo "medium"
        return
    fi
    if [[ "$cmd" =~ kill[[:space:]]+-9[[:space:]]+-1 ]]; then
        echo "medium"
        return
    fi
    if [[ "$cmd" =~ pkill[[:space:]]+-f ]]; then
        echo "medium"
        return
    fi

    echo "safe"
}
