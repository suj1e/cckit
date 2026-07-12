#!/usr/bin/env bash
# hooks.sh — Hook logic functions for barnhk

# Each function receives no arguments; input JSON is in $INPUT, PROJECT_NAME is set.
# Functions echo JSON output to stdout and exit with appropriate code.
# NOTE: No side effects (no network, no filesystem writes outside config).
#       Hooks only make allow/deny decisions and return JSON.

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
        echo '{"hookSpecificOutput":{"hookEventName":"PermissionRequest","decision":{"behavior":"allow"}}}'
        exit 0
    fi

    # Manual approval needed — Claude Code will prompt the user
    exit 0
}

hook_task_completed() {
    exit 0
}

hook_stop() {
    exit 0
}

hook_session_end() {
    exit 0
}

hook_teammate_idle() {
    exit 0
}
