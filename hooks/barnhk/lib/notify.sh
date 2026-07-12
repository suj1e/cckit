#!/usr/bin/env bash
# notify.sh — EchoBell webhook notification for barnhk

# Send a notification via EchoBell webhook.
# Usage: send_echobell_notification <title> <body>
# Expects ECHOBELL_TOKEN to be set.
send_echobell_notification() {
    local title="$1" body="$2"

    curl -s -m 5 -X POST "https://hook.echobell.one/t/$ECHOBELL_TOKEN" \
        -H "Content-Type: application/json" \
        -d "$(jq -nc --arg title "$title" --arg body "$body" \
            '{title: $title, body: $body}')" \
        >/dev/null 2>&1 || true
}

# Send a notification (silent skip if token not configured).
# Usage: send_notification <title> <body> [project_name]
send_notification() {
    local title="$1" body="$2" project_name="${3:-}"

    if [[ -z "$ECHOBELL_TOKEN" ]]; then
        return 0
    fi

    if [[ -n "$project_name" ]]; then
        title="[$project_name] $title"
    fi

    send_echobell_notification "$title" "$body"
}
