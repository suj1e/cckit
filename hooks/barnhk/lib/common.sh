#!/usr/bin/env bash
# common.sh — Entry point for barnhk hooks

BARNHK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BARNHK_ENV="$BARNHK_DIR/barnhk.env"

# ── Source sub-modules ────────────────────────────────────────────────────────

source "$BARNHK_DIR/safety.sh"
source "$BARNHK_DIR/notify.sh"
source "$BARNHK_DIR/transcript.sh"
source "$BARNHK_DIR/hooks.sh"

# ── Configuration ─────────────────────────────────────────────────────────────

# Stable user config path (survives plugin updates and works with any install method)
USER_BARNHK_ENV="${HOME}/.claude/cckit/barnhk.env"

load_config() {
    # 1. Prefer user's stable config (survives updates and npm installs)
    if [[ -f "$USER_BARNHK_ENV" ]]; then
        source "$USER_BARNHK_ENV"
        return 0
    fi

    # 2. Fall back to bundled template
    if [[ -f "$BARNHK_ENV" ]]; then
        # Auto-copy template to stable location on first run
        mkdir -p "$(dirname "$USER_BARNHK_ENV")"
        cp "$BARNHK_ENV" "$USER_BARNHK_ENV"
        source "$USER_BARNHK_ENV"
        return 0
    fi
}

# ── Utility functions ─────────────────────────────────────────────────────────

json_value() {
    local key="$1"
    jq -r "$key // empty" 2>/dev/null
}

truncate_string() {
    local str="$1" max_len="${2:-100}"
    if [[ ${#str} -gt $max_len ]]; then
        echo "${str:0:$max_len}..."
    else
        echo "$str"
    fi
}

get_icon() {
    case "$1" in
        permission_prompt) echo "🔐" ;;
        question)          echo "❓" ;;
        idle_prompt)       echo "⏳" ;;
        *)                 echo "🔔" ;;
    esac
}

get_notification_mode() {
    local notif_type="$1"
    case "$notif_type" in
        permission_prompt) echo "${NOTIFICATION_PERMISSION_PROMPT:-skip}" ;;
        question)          echo "${NOTIFICATION_QUESTION:-transcript}" ;;
        idle_prompt)       echo "${NOTIFICATION_IDLE_PROMPT:-transcript}" ;;
        *)                 echo "default" ;;
    esac
}

get_notification_title() {
    local notif_type="$1"
    case "$notif_type" in
        question)    echo "${TITLE_QUESTION:-❓ Claude Question}" ;;
        idle_prompt) echo "${TITLE_IDLE_PROMPT:-⏳ Claude Waiting}" ;;
        *)           echo "${TITLE_QUESTION:-❓ Claude Question}" ;;
    esac
}

# ── Hook dispatcher ───────────────────────────────────────────────────────────

dispatch_hook() {
    local hook_name="$1"

    load_config

    INPUT=$(cat)

    CWD=$(echo "$INPUT" | json_value '.cwd')

    PROJECT_NAME=""
    if [[ -n "$CWD" ]]; then
        PROJECT_NAME=$(basename "$CWD")
    elif [[ -n "$PWD" ]]; then
        PROJECT_NAME=$(basename "$PWD")
    fi

    case "$hook_name" in
        pre-tool-use)       hook_pre_tool_use ;;
        permission-request) hook_permission_request ;;
        task-completed)     hook_task_completed ;;
        stop)               hook_stop ;;
        session-end)        hook_session_end ;;
        teammate-idle)      hook_teammate_idle ;;
        notification)       hook_notification ;;
        *)                  echo "Unknown hook: $hook_name" >&2; exit 1 ;;
    esac
}
