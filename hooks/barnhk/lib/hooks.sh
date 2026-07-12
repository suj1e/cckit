#!/usr/bin/env bash
# hooks.sh — Hook logic functions for barnhk

# Each function receives no arguments; input JSON is in $INPUT, PROJECT_NAME is set.
# Functions echo JSON output to stdout and exit with appropriate code.

hook_pre_tool_use() {
    local TOOL_NAME=$(echo "$INPUT" | json_value '.tool_name')
    local COMMAND=$(echo "$INPUT" | json_value '.tool_input.command')

    # Only check Bash tool commands
    if [[ "$TOOL_NAME" != "Bash" ]] || [[ -z "$COMMAND" ]]; then
        exit 0
    fi

    local DANGER_LEVEL=$(check_danger_level "$COMMAND")

    case "$DANGER_LEVEL" in
        critical|high)
            local REASON
            [[ "$DANGER_LEVEL" == "critical" ]] && REASON="Critical dangerous command detected: $COMMAND"
            [[ "$DANGER_LEVEL" == "high" ]] && REASON="High-risk command detected: $COMMAND"
            echo "BLOCKED: $REASON" >&2
            send_notification "$TITLE_DANGER" "Blocked: $COMMAND" "$PROJECT_NAME"
            jq -n --arg reason "$REASON" '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$reason}}'
            exit 2
            ;;
        *)
            exit 0
            ;;
    esac
}

hook_permission_request() {
    local TOOL_NAME=$(echo "$INPUT" | json_value '.tool_name')
    local COMMAND=$(echo "$INPUT" | json_value '.tool_input.command')
    local FILE_PATH=$(echo "$INPUT" | json_value '.tool_input.path')
    local SESSION_ID=$(echo "$INPUT" | json_value '.session_id')

    # Debug logging
    if [[ "${DEBUG_ENABLED:-false}" == "true" ]]; then
        echo "[$(date)] INPUT: $INPUT" >> "/tmp/barnhk-permission-debug.log"
    fi

    local TRUNCATED_CMD=$(truncate_string "$COMMAND" 100)
    local TOOL_LABEL="[$(echo "$TOOL_NAME" | tr '[:lower:]' '[:upper:]')]"

    # Auto-approve Edit/Write for files within project directory
    if [[ "$TOOL_NAME" == "Edit" ]] || [[ "$TOOL_NAME" == "Write" ]]; then
        FILE_PATH=$(echo "$INPUT" | json_value '.tool_input.file_path // .tool_input.path')
        if [[ -n "$FILE_PATH" ]] && [[ -n "$CWD" ]]; then
            if [[ "$FILE_PATH" == "$CWD"* ]]; then
                echo "[barnhk] Auto-approving: $TOOL_NAME $FILE_PATH" >&2
                echo '{"hookSpecificOutput":{"hookEventName":"PermissionRequest","decision":{"behavior":"allow"}}}'
                exit 0
            fi
        fi
    fi

    # Auto-approve safe bash commands
    if [[ "$TOOL_NAME" == "Bash" ]] && [[ -n "$COMMAND" ]] && is_safe_command "$COMMAND" "$CWD"; then
        echo "[barnhk] Auto-approving: $COMMAND" >&2
        local OUTPUT='{"hookSpecificOutput":{"hookEventName":"PermissionRequest","decision":{"behavior":"allow"}}}'
        echo "$OUTPUT"
        [[ "${DEBUG_ENABLED:-false}" == "true" ]] && echo "[$(date)] OUTPUT: $OUTPUT" >> "/tmp/barnhk-permission-debug.log"
        local BODY="$TOOL_LABEL Auto-approved"$'\n'"Cmd: $TRUNCATED_CMD"
        send_notification "$TITLE_PERMIT" "$BODY" "$PROJECT_NAME"
        exit 0
    fi

    # Manual approval needed
    local BODY="$TOOL_LABEL Manual approval needed"
    [[ -n "$COMMAND" ]] && BODY="$BODY"$'\n'"Cmd: $TRUNCATED_CMD"
    [[ -n "$FILE_PATH" ]] && BODY="$BODY"$'\n'"Path: $FILE_PATH"
    [[ -n "$SESSION_ID" ]] && BODY="$BODY"$'\n'"Session: $SESSION_ID"

    send_notification "$TITLE_APPROVAL" "$BODY" "$PROJECT_NAME"
    exit 0
}

hook_task_completed() {
    local TASK_ID=$(echo "$INPUT" | json_value '.task_id')
    local TASK_SUBJECT=$(echo "$INPUT" | json_value '.task_subject')
    local TEAMMATE_NAME=$(echo "$INPUT" | json_value '.teammate_name')
    local TEAM_NAME=$(echo "$INPUT" | json_value '.team_name')

    local BODY="Task completed"
    [[ -n "$TASK_SUBJECT" ]] && BODY="$BODY"$'\n'"Subject: $TASK_SUBJECT"
    [[ -n "$TASK_ID" ]] && BODY="$BODY"$'\n'"Task ID: $TASK_ID"
    [[ -n "$TEAMMATE_NAME" ]] && BODY="$BODY"$'\n'"By: $TEAMMATE_NAME"
    [[ -n "$TEAM_NAME" ]] && BODY="$BODY"$'\n'"Team: $TEAM_NAME"

    send_notification "$TITLE_DONE" "$BODY" "$PROJECT_NAME"
    exit 0
}

hook_stop() {
    local SESSION_ID=$(echo "$INPUT" | json_value '.session_id')
    local LAST_MESSAGE=$(echo "$INPUT" | json_value '.last_assistant_message')

    local BODY="Session: ${SESSION_ID:-unknown}"
    if [[ -n "$LAST_MESSAGE" ]]; then
        local TRUNCATED_MSG=$(truncate_string "$LAST_MESSAGE" 200)
        BODY="$BODY"$'\n'"Message: $TRUNCATED_MSG"
    fi

    send_notification "$TITLE_STOP" "$BODY" "$PROJECT_NAME"
    exit 0
}

hook_session_end() {
    local SESSION_ID=$(echo "$INPUT" | json_value '.session_id')
    local END_REASON=$(echo "$INPUT" | json_value '.reason')

    local BODY="[SESSION] Session ended"
    [[ -n "$SESSION_ID" ]] && BODY="$BODY"$'\n'"Session: $SESSION_ID"
    [[ -n "$END_REASON" ]] && BODY="$BODY"$'\n'"Reason: $END_REASON"

    send_notification "$TITLE_STOP" "$BODY" "$PROJECT_NAME"
    exit 0
}

hook_teammate_idle() {
    local TEAMMATE_NAME=$(echo "$INPUT" | json_value '.teammate_name')
    local TEAM_NAME=$(echo "$INPUT" | json_value '.team_name')

    local BODY="Teammate idle"
    [[ -n "$TEAMMATE_NAME" ]] && BODY="Teammate: $TEAMMATE_NAME"
    [[ -n "$TEAM_NAME" ]] && BODY="$BODY"$'\n'"Team: $TEAM_NAME"

    send_notification "$TITLE_IDLE" "$BODY" "$PROJECT_NAME"
    exit 0
}

hook_notification() {
    local SESSION_ID=$(echo "$INPUT" | json_value '.session_id')
    local MESSAGE=$(echo "$INPUT" | json_value '.message')
    local NOTIFICATION_TYPE=$(echo "$INPUT" | json_value '.notification_type')
    local TRANSCRIPT_PATH=$(echo "$INPUT" | json_value '.transcript_path')

    local MODE=$(get_notification_mode "$NOTIFICATION_TYPE")
    [[ "$MODE" == "skip" ]] && exit 0

    local NOTIF_CONTENT=""
    if [[ "$MODE" == "transcript" ]] && [[ -n "$TRANSCRIPT_PATH" ]] && [[ -n "$SESSION_ID" ]]; then
        NOTIF_CONTENT=$(extract_transcript_content "$TRANSCRIPT_PATH" "$SESSION_ID" 200 2>/dev/null) || true
    fi

    if [[ -z "$NOTIF_CONTENT" ]]; then
        NOTIF_CONTENT=$(truncate_string "${MESSAGE:-Claude needs your attention}" 200)
    fi

    local ICON=$(get_icon "$NOTIFICATION_TYPE")
    local NOTIF_BODY="$ICON $NOTIF_CONTENT"
    [[ -n "$SESSION_ID" ]] && NOTIF_BODY="$NOTIF_BODY"$'\n'"Session: $SESSION_ID"

    local NOTIF_TITLE=$(get_notification_title "$NOTIFICATION_TYPE")
    send_notification "$NOTIF_TITLE" "$NOTIF_BODY" "$PROJECT_NAME"
    exit 0
}
