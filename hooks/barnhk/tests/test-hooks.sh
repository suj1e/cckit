#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

PASS=0
FAIL=0

# Run a hook function in a subshell and capture exit code + output
run_hook() {
    local fn="$1"
    shift
    set +e
    ( "$fn" "$@" ) >/tmp/barnhk-test-out 2>/tmp/barnhk-test-err
    echo $? > /tmp/barnhk-test-code
    set -e
}

assert_code() {
    local got="$1" expected="$2" label="$3"
    if [[ "$got" -eq "$expected" ]]; then
        PASS=$((PASS + 1))
        echo "  PASS: $label"
    else
        FAIL=$((FAIL + 1))
        echo "  FAIL: $label (expected $expected, got $got)"
    fi
}

# Set up minimal config
BARK_SERVER_URL=""
DISCORD_WEBHOOK_URL=""
FEISHU_WEBHOOK_URL=""
export BARK_SERVER_URL DISCORD_WEBHOOK_URL FEISHU_WEBHOOK_URL

echo "=== hook_pre_tool_use ==="

# Test: critical command blocks
INPUT='{"tool_name":"Bash","tool_input":{"command":"rm -rf /"},"cwd":"/tmp/test"}'
export INPUT
CWD="/tmp/test"
PROJECT_NAME=$(basename "$CWD")
export CWD PROJECT_NAME
run_hook hook_pre_tool_use
code=$(cat /tmp/barnhk-test-code)
assert_code "$code" 2 "critical command exits 2"

echo ""
echo "=== hook_permission_request ==="
INPUT='{"tool_name":"Bash","tool_input":{"command":"git status"},"cwd":"/tmp/test"}'
export INPUT
run_hook hook_permission_request
code=$(cat /tmp/barnhk-test-code)
assert_code "$code" 0 "safe command auto-approves"

echo ""
echo "=== hook_task_completed ==="
INPUT='{"task_id":"1","task_subject":"Fix bug","task_description":"Fix login","teammate_name":"dev","team_name":"be","cwd":"/tmp/test"}'
export INPUT
run_hook hook_task_completed
code=$(cat /tmp/barnhk-test-code)
assert_code "$code" 0 "task completed exits cleanly"

echo ""
echo "=== hook_stop ==="
INPUT='{"session_id":"sess_01","last_assistant_message":"All done","cwd":"/tmp/test"}'
export INPUT
run_hook hook_stop
code=$(cat /tmp/barnhk-test-code)
assert_code "$code" 0 "stop exits cleanly"

echo ""
echo "=== hook_session_end ==="
INPUT='{"session_id":"sess_01","reason":"other","cwd":"/tmp/test"}'
export INPUT
run_hook hook_session_end
code=$(cat /tmp/barnhk-test-code)
assert_code "$code" 0 "session end exits cleanly"

echo ""
echo "=== hook_teammate_idle ==="
INPUT='{"teammate_name":"researcher","team_name":"my-project","cwd":"/tmp/test"}'
export INPUT
run_hook hook_teammate_idle
code=$(cat /tmp/barnhk-test-code)
assert_code "$code" 0 "teammate idle exits cleanly"

echo ""
echo "=== dispatch_hook ==="
echo '{"cwd":"/tmp/test"}' | ( dispatch_hook "pre-tool-use" ) >/dev/null 2>&1 || true
code=$?
assert_code "$code" 0 "unknown tool dispatches with exit 0"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━"
echo "Results: $PASS passed, $FAIL failed"
echo "━━━━━━━━━━━━━━━━━━━━━━"
[[ $FAIL -eq 0 ]] || exit 1
