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

# Truncate string to max length
# Usage: truncate_string <string> <max_length>
truncate_string() {
    local str="$1"
    local max_len="${2:-100}"
    if [[ ${#str} -gt $max_len ]]; then
        echo "${str:0:$max_len}..."
    else
        echo "$str"
    fi
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

# Get Discord embed color for notification group
# Usage: get_discord_color <group>
get_discord_color() {
    local group="$1"
    case "$group" in
        claude-danger)
            echo "${DISCORD_COLOR_DANGER:-15548997}"
            ;;
        claude-permit|claude-auto-permit)
            echo "${DISCORD_COLOR_PERMIT:-5763719}"
            ;;
        claude-manual-permit)
            echo "${DISCORD_COLOR_APPROVAL:-16776960}"
            ;;
        claude-done)
            echo "${DISCORD_COLOR_DONE:-3066993}"
            ;;
        claude-stop)
            echo "${DISCORD_COLOR_STOP:-15105570}"
            ;;
        claude-idle)
            echo "${DISCORD_COLOR_IDLE:-8421504}"
            ;;
        claude-question)
            echo "10181046"
            ;;
        *)
            echo "7506394"
            ;;
    esac
}

# Send Discord notification via webhook (optional, silent failure)
# Usage: send_discord_notification <group> <title> <body>
send_discord_notification() {
    local group="$1"
    local title="$2"
    local body="$3"

    # Skip if not configured
    if [[ -z "$DISCORD_WEBHOOK_URL" ]]; then
        return 0
    fi

    # Validate URL format
    if [[ ! "$DISCORD_WEBHOOK_URL" =~ ^https?:// ]]; then
        return 0
    fi

    # Get color for this group
    local color=$(get_discord_color "$group")

    # Escape JSON special characters in title and body
    local escaped_title=$(echo "$title" | jq -Rs '. | gsub("\\n"; "\\n") | gsub("\""; "\\\"") | gsub("\t"; "\\t") | .[0:-1]')
    local escaped_body=$(echo "$body" | jq -Rs '. | gsub("\\n"; "\\n") | gsub("\""; "\\\"") | gsub("\t"; "\\t") | .[0:-1]')

    # Build Discord embed JSON payload
    local payload=$(cat <<EOF
{
  "embeds": [{
    "title": $escaped_title,
    "description": $escaped_body,
    "color": $color,
    "footer": {"text": "$group"}
  }]
}
EOF
)

    # Send notification (silent failure)
    curl -s -m 5 -X POST \
        -H "Content-Type: application/json" \
        -d "$payload" \
        "$DISCORD_WEBHOOK_URL" >/dev/null 2>&1 || true
}

# Get Feishu card template color for notification group
# Usage: get_feishu_color <group>
get_feishu_color() {
    local group="$1"
    case "$group" in
        claude-danger)
            echo "red"
            ;;
        claude-permit|claude-auto-permit)
            echo "green"
            ;;
        claude-manual-permit)
            echo "yellow"
            ;;
        claude-done)
            echo "blue"
            ;;
        claude-stop)
            echo "orange"
            ;;
        claude-idle)
            echo "grey"
            ;;
        claude-question)
            echo "purple"
            ;;
        *)
            echo "blue"
            ;;
    esac
}

# Get icon for field name
# Usage: get_field_icon <field_name>
get_field_icon() {
    local field="$1"
    case "$field" in
        Cmd) echo "⌨️" ;;
        Path) echo "📁" ;;
        Session) echo "🔗" ;;
        Reason) echo "💡" ;;
        Tool) echo "🔧" ;;
        *) echo "📌" ;;
    esac
}

# Parse body text into structured fields
# Input: body text with "Key: Value" format
# Output: JSON with first_line and fields array
# Usage: parse_body_fields <body>
parse_body_fields() {
    local body="$1"
    local first_line=""
    local fields_json="[]"

    # Process each line
    while IFS= read -r line || [[ -n "$line" ]]; do
        # Skip empty lines
        [[ -z "$line" ]] && continue

        # First non-empty line is the status description
        if [[ -z "$first_line" ]]; then
            first_line="$line"
            continue
        fi

        # Check for "Key: Value" pattern
        if [[ "$line" =~ ^([^:]+):\ (.+)$ ]]; then
            local key="${BASH_REMATCH[1]}"
            local value="${BASH_REMATCH[2]}"
            local icon=$(get_field_icon "$key")
            local label="${icon} ${key}"

            # Build field JSON using jq with proper string args
            local field_json
            field_json=$(jq -n \
                --arg label "$label" \
                --arg value "$value" \
                '{"tag": "div", "text": {"tag": "lark_md", "content": ("**" + $label + "**  \n" + $value)}}')

            # Append to fields array
            fields_json=$(echo "$fields_json" | jq --argjson field "$field_json" '. + [$field]')
        fi
    done <<< "$body"

    # Return JSON with first_line and fields
    local escaped_first_line
    escaped_first_line=$(echo "$first_line" | jq -Rs '. | gsub("\n"; " ") | .[0:-1]')

    echo "{\"first_line\": $escaped_first_line, \"fields\": $fields_json}"
}

# Send Feishu notification via webhook (optional, silent failure)
# Usage: send_feishu_notification <group> <title> <body>
send_feishu_notification() {
    local group="$1"
    local title="$2"
    local body="$3"

    # Skip if not configured
    if [[ -z "$FEISHU_WEBHOOK_URL" ]]; then
        return 0
    fi

    # Validate URL format
    if [[ ! "$FEISHU_WEBHOOK_URL" =~ ^https?:// ]]; then
        return 0
    fi

    # Get color for this group
    local color=$(get_feishu_color "$group")

    # Try to parse body into structured fields
    local parsed
    parsed=$(parse_body_fields "$body" 2>/dev/null)

    local elements_json

    if [[ -n "$parsed" ]] && echo "$parsed" | jq -e '.fields | length > 0' >/dev/null 2>&1; then
        # Structured format: first line + hr + fields + note
        local first_line=$(echo "$parsed" | jq -r '.first_line')
        local fields=$(echo "$parsed" | jq '.fields')

        # Build elements array using jq
        elements_json=$(jq -n \
            --arg first_line "📋 $first_line" \
            --arg group "$group" \
            --argjson fields "$fields" '
            [
                {"tag": "div", "text": {"tag": "plain_text", "content": $first_line}},
                {"tag": "hr"}
            ] + $fields + [
                {"tag": "note", "elements": [{"tag": "plain_text", "content": $group}]}
            ]
        ')
    else
        # Fallback: simple format
        elements_json=$(jq -n \
            --arg body "$body" \
            --arg group "$group" '
            [
                {"tag": "div", "text": {"tag": "plain_text", "content": $body}},
                {"tag": "note", "elements": [{"tag": "plain_text", "content": $group}]}
            ]
        ')
    fi

    # Build complete payload using jq
    local payload
    payload=$(jq -n \
        --arg title "$title" \
        --arg color "$color" \
        --argjson elements "$elements_json" '
        {
            "msg_type": "interactive",
            "card": {
                "header": {
                    "title": {"tag": "plain_text", "content": $title},
                    "template": $color
                },
                "elements": $elements
            }
        }
    ')

    # Send notification (silent failure)
    curl -s -m 5 -X POST \
        -H "Content-Type: application/json" \
        -d "$payload" \
        "$FEISHU_WEBHOOK_URL" >/dev/null 2>&1 || true
}

# Send notification to all configured backends
# Usage: send_notification <group> <title> <body> [project_name]
send_notification() {
    local group="$1"
    local title="$2"
    local body="$3"
    local project_name="${4:-}"

    # Prepend project name to title if provided
    if [[ -n "$project_name" ]]; then
        title="[$project_name] $title"
    fi

    # Send to Bark (iOS push)
    send_bark_notification "$group" "$title" "$body"

    # Send to Discord (webhook)
    send_discord_notification "$group" "$title" "$body"

    # Send to Feishu (webhook)
    send_feishu_notification "$group" "$title" "$body"
}

# Check if cplit integration is enabled and configured
# Usage: is_cplit_enabled
is_cplit_enabled() {
    [[ "$CPLIT_ENABLED" == "true" ]] && [[ -n "$CPLIT_URL" ]] && [[ "$CPLIT_URL" =~ ^https?:// ]]
}

# Request approval from cplit server
# Returns: "approve", "deny", or empty string on error
# Usage: request_cplit_approval <command> <cwd>
request_cplit_approval() {
    local command="$1"
    local cwd="$2"

    # Skip if not configured
    if ! is_cplit_enabled; then
        echo ""
        return 1
    fi

    # Escape command and cwd for JSON using jq
    local escaped_command
    local escaped_cwd
    escaped_command=$(echo "$command" | jq -Rs '.[0:-1]')
    escaped_cwd=$(echo "$cwd" | jq -Rs '.[0:-1]')

    # Build JSON payload
    local payload="{\"command\":$escaped_command,\"cwd\":$escaped_cwd}"

    # Call cplit API with timeout (70s to allow for cplit's 60s timeout)
    local response
    response=$(curl -s -m 70 -X POST \
        -H "Content-Type: application/json" \
        -d "$payload" \
        "${CPLIT_URL%/}/request-approval" 2>/dev/null)

    # Parse decision from response
    if [[ -n "$response" ]]; then
        local decision
        decision=$(echo "$response" | jq -r '.decision // empty' 2>/dev/null)
        if [[ "$decision" == "approve" ]] || [[ "$decision" == "deny" ]]; then
            echo "$decision"
            return 0
        fi
    fi

    # Error or unexpected response
    echo ""
    return 1
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

    # OpenSpec workflow commands
    if [[ "$cmd" =~ ^openspec[[:space:]]+(list|propose|apply|archive|explore|status|init|new) ]]; then
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
