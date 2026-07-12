#!/usr/bin/env bash
# notify.sh — Multi-channel notification backends for barnhk

# ── Bark (iOS Push) ───────────────────────────────────────────────────────────

send_bark_notification() {
    local group="$1" title="$2" body="$3"

    if [[ -z "$BARK_SERVER_URL" ]] || [[ ! "$BARK_SERVER_URL" =~ ^https?:// ]]; then
        return 0
    fi

    local sound=""
    case "$group" in
        claude-danger) sound="alarm.caf" ;;
        claude-permit) sound="bell.caf" ;;
        claude-done)   sound="glass.caf" ;;
    esac

    local encoded_title=$(printf '%s' "$title" | jq -sRr @uri)
    local encoded_body=$(printf '%s' "$body" | jq -sRr @uri)
    local encoded_group=$(printf '%s' "$group" | jq -sRr @uri)

    local url="${BARK_SERVER_URL%/}/${encoded_title}/${encoded_body}?group=${encoded_group}"
    [[ -n "$sound" ]] && url="${url}&sound=${sound}"

    curl -s -m 3 "$url" >/dev/null 2>&1 || true
}

# ── Discord Webhook ───────────────────────────────────────────────────────────

get_discord_color() {
    local group="$1"
    case "$group" in
        claude-danger)       echo "${DISCORD_COLOR_DANGER:-15548997}" ;;
        claude-permit|claude-auto-permit) echo "${DISCORD_COLOR_PERMIT:-5763719}" ;;
        claude-manual-permit) echo "${DISCORD_COLOR_APPROVAL:-16776960}" ;;
        claude-done)          echo "${DISCORD_COLOR_DONE:-3066993}" ;;
        claude-stop)          echo "${DISCORD_COLOR_STOP:-15105570}" ;;
        claude-idle)          echo "${DISCORD_COLOR_IDLE:-8421504}" ;;
        claude-question)      echo "10181046" ;;
        *)                    echo "7506394" ;;
    esac
}

send_discord_notification() {
    local group="$1" title="$2" body="$3"

    if [[ -z "$DISCORD_WEBHOOK_URL" ]] || [[ ! "$DISCORD_WEBHOOK_URL" =~ ^https?:// ]]; then
        return 0
    fi

    local color=$(get_discord_color "$group")
    local escaped_title=$(echo "$title" | jq -Rs '. | gsub("\\n"; "\\n") | gsub("\""; "\\\"") | gsub("\t"; "\\t") | .[0:-1]')
    local escaped_body=$(echo "$body" | jq -Rs '. | gsub("\\n"; "\\n") | gsub("\""; "\\\"") | gsub("\t"; "\\t") | .[0:-1]')

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
    curl -s -m 5 -X POST -H "Content-Type: application/json" \
        -d "$payload" "$DISCORD_WEBHOOK_URL" >/dev/null 2>&1 || true
}

# ── Feishu Webhook ────────────────────────────────────────────────────────────

get_feishu_color() {
    local group="$1"
    case "$group" in
        claude-danger)       echo "red" ;;
        claude-permit|claude-auto-permit) echo "green" ;;
        claude-manual-permit) echo "yellow" ;;
        claude-done)          echo "blue" ;;
        claude-stop)          echo "orange" ;;
        claude-idle)          echo "grey" ;;
        claude-question)      echo "purple" ;;
        *)                    echo "blue" ;;
    esac
}

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

parse_body_fields() {
    local body="$1"
    local first_line="" fields_json="[]"

    while IFS= read -r line || [[ -n "$line" ]]; do
        [[ -z "$line" ]] && continue
        if [[ -z "$first_line" ]]; then
            first_line="$line"
            continue
        fi
        if [[ "$line" =~ ^([^:]+):\ (.+)$ ]]; then
            local key="${BASH_REMATCH[1]}" value="${BASH_REMATCH[2]}"
            local icon=$(get_field_icon "$key")
            local label="${icon} ${key}"
            local field_json
            field_json=$(jq -n --arg label "$label" --arg value "$value" \
                '{"tag":"div","text":{"tag":"lark_md","content":("**"+$label+"**  \n"+$value)}}')
            fields_json=$(echo "$fields_json" | jq --argjson field "$field_json" '. + [$field]')
        fi
    done <<< "$body"

    local escaped_first_line=$(echo "$first_line" | jq -Rs '. | gsub("\n"; " ") | .[0:-1]')
    echo "{\"first_line\": $escaped_first_line, \"fields\": $fields_json}"
}

send_feishu_notification() {
    local group="$1" title="$2" body="$3"

    if [[ -z "$FEISHU_WEBHOOK_URL" ]] || [[ ! "$FEISHU_WEBHOOK_URL" =~ ^https?:// ]]; then
        return 0
    fi

    local color=$(get_feishu_color "$group")
    local parsed=$(parse_body_fields "$body" 2>/dev/null)
    local elements_json

    if [[ -n "$parsed" ]] && echo "$parsed" | jq -e '.fields | length > 0' >/dev/null 2>&1; then
        local first_line=$(echo "$parsed" | jq -r '.first_line')
        local fields=$(echo "$parsed" | jq '.fields')
        elements_json=$(jq -n \
            --arg first_line "📋 $first_line" \
            --arg group "$group" \
            --argjson fields "$fields" \
            '[{"tag":"div","text":{"tag":"plain_text","content":$first_line}},{"tag":"hr"}]+$fields+[{"tag":"note","elements":[{"tag":"plain_text","content":$group}]}]')
    else
        elements_json=$(jq -n \
            --arg body "$body" \
            --arg group "$group" \
            '[{"tag":"div","text":{"tag":"plain_text","content":$body}},{"tag":"note","elements":[{"tag":"plain_text","content":$group}]}]')
    fi

    local payload=$(jq -n \
        --arg title "$title" \
        --arg color "$color" \
        --argjson elements "$elements_json" \
        '{"msg_type":"interactive","card":{"header":{"title":{"tag":"plain_text","content":$title},"template":$color},"elements":$elements}}')

    curl -s -m 5 -X POST -H "Content-Type: application/json" \
        -d "$payload" "$FEISHU_WEBHOOK_URL" >/dev/null 2>&1 || true
}

# ── Dispatch ──────────────────────────────────────────────────────────────────

send_notification() {
    local group="$1" title="$2" body="$3" project_name="${4:-}"

    if [[ -n "$project_name" ]]; then
        title="[$project_name] $title"
    fi

    send_bark_notification "$group" "$title" "$body"
    send_discord_notification "$group" "$title" "$body"
    send_feishu_notification "$group" "$title" "$body"
}
