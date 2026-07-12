#!/usr/bin/env bash
# safety.sh — Command safety checks for barnhk hooks

# Check if command matches safe whitelist
# Usage: is_safe_command <command> [cwd]
is_safe_command() {
    local cmd="$1"
    local cwd="${2:-}"

    # Project directory auto-approve (if enabled)
    if [[ "$AUTO_APPROVE_PROJECT_COMMANDS" == "true" ]] && [[ -n "$cwd" ]]; then
        return 0
    fi

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

    # OpenSpec workflow commands
    if [[ "$cmd" =~ ^openspec[[:space:]]+ ]]; then
        return 0
    fi

    # Directory operations
    if [[ "$cmd" =~ ^mkdir[[:space:]]+ ]]; then
        return 0
    fi

    # File operations
    if [[ "$cmd" =~ ^(touch|cp|mv)[[:space:]]+ ]]; then
        return 0
    fi

    # Docker commands
    if [[ "$cmd" =~ ^docker[[:space:]]+(ps|ls|images|logs|inspect|stats|top|port|exec)([[:space:]]|$) ]]; then
        return 0
    fi
    if [[ "$cmd" =~ ^docker[[:space:]]+(network|volume)[[:space:]]+ls ]]; then
        return 0
    fi

    # Docker compose
    if [[ "$cmd" =~ ^docker-compose[[:space:]]+(up|down|logs|ps|build|config)([[:space:]]|$) ]]; then
        return 0
    fi
    if [[ "$cmd" =~ ^docker[[:space:]]+compose[[:space:]]+(up|down|logs|ps|build|config)([[:space:]]|$) ]]; then
        return 0
    fi

    # Custom whitelist
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
# Returns: safe, medium, high, critical
check_danger_level() {
    local cmd="$1"

    # Critical — always block
    if [[ "$cmd" =~ rm[[:space:]]+-rf[[:space:]]+(/|/\*) ]]; then
        echo "critical"; return
    fi
    if [[ "$cmd" =~ dd[[:space:]].*of=/dev/ ]]; then
        echo "critical"; return
    fi
    if [[ "$cmd" =~ mkfs[[:space:]] ]]; then
        echo "critical"; return
    fi

    # High — block
    if [[ "$cmd" =~ ^sudo[[:space:]] ]]; then
        echo "high"; return
    fi
    if [[ "$cmd" =~ (curl|wget).*\|[[:space:]]*(bash|sh) ]]; then
        echo "high"; return
    fi
    if [[ "$cmd" =~ chmod[[:space:]]+-R[[:space:]]+777 ]]; then
        echo "high"; return
    fi
    if [[ "$cmd" =~ chmod[[:space:]]+777[[:space:]]+/ ]]; then
        echo "high"; return
    fi

    # Medium — allow but noteworthy
    if [[ "$cmd" =~ (nc|netcat)[[:space:]]+-l ]]; then
        echo "medium"; return
    fi
    if [[ "$cmd" =~ kill[[:space:]]+-9[[:space:]]+-1 ]]; then
        echo "medium"; return
    fi
    if [[ "$cmd" =~ pkill[[:space:]]+-f ]]; then
        echo "medium"; return
    fi

    echo "safe"
}
