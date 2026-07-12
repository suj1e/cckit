#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/notify.sh"

PASS=0
FAIL=0

assert_not_empty() {
    local got="$1" label="$2"
    if [[ -n "$got" ]]; then
        PASS=$((PASS + 1))
        echo "  PASS: $label (length ${#got})"
    else
        FAIL=$((FAIL + 1))
        echo "  FAIL: $label (empty output)"
    fi
}

echo "=== get_discord_color ==="
c=$(get_discord_color "claude-danger")
assert_not_empty "$c" "claude-danger returns a color"

c=$(get_discord_color "unknown-group")
assert_not_empty "$c" "unknown group returns fallback color"

echo ""
echo "=== get_feishu_color ==="
c=$(get_feishu_color "claude-permit")
assert_not_empty "$c" "claude-permit returns a color"

echo ""
echo "=== get_field_icon ==="
assert_not_empty "$(get_field_icon "Cmd")" "Cmd has icon"
assert_not_empty "$(get_field_icon "Path")" "Path has icon"
assert_not_empty "$(get_field_icon "Session")" "Session has icon"
assert_not_empty "$(get_field_icon "Unknown")" "Unknown field has fallback icon"

echo ""
echo "=== send_notification (dry-run: no URLs configured) ==="
# With no URLs configured, send_notification should succeed silently
BARK_SERVER_URL=""
DISCORD_WEBHOOK_URL=""
FEISHU_WEBHOOK_URL=""
if send_notification "test" "Test Title" "Test Body" "test-project"; then
    PASS=$((PASS + 1))
    echo "  PASS: send_notification succeeds with no backends configured"
else
    FAIL=$((FAIL + 1))
    echo "  FAIL: send_notification failed"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━"
echo "Results: $PASS passed, $FAIL failed"
echo "━━━━━━━━━━━━━━━━━━━━━━"
[[ $FAIL -eq 0 ]] || exit 1
