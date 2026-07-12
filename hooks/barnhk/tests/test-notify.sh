#!/usr/bin/env bash
# test-notify.sh — Tests for barnhk's EchoBell webhook notifications
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/notify.sh"

PASS=0
FAIL=0

assert_contains() {
    local file="$1" needle="$2" label="$3"
    if [[ -f "$file" ]] && grep -qF -- "$needle" "$file"; then
        PASS=$((PASS + 1))
        echo "  PASS: $label"
    else
        FAIL=$((FAIL + 1))
        echo "  FAIL: $label (missing '$needle' in $file)"
    fi
}

assert_not_contains() {
    local file="$1" needle="$2" label="$3"
    if [[ -f "$file" ]] && ! grep -qF -- "$needle" "$file"; then
        PASS=$((PASS + 1))
        echo "  PASS: $label"
    else
        FAIL=$((FAIL + 1))
        echo "  FAIL: $label (unexpectedly contains '$needle')"
    fi
}

CURL_LOG_FILE="$(mktemp -t barnhk-notify-test.XXXXXX)"
trap 'rm -f "$CURL_LOG_FILE"' EXIT

# Stub curl: log each arg on its own line, no network
curl() {
    printf '%s\n' "$@" >> "$CURL_LOG_FILE"
    return 0
}

echo "=== send_notification with empty ECHOBELL_TOKEN (silent skip) ==="
ECHOBELL_TOKEN=""
> "$CURL_LOG_FILE"
if send_notification "Title" "Body" "my-project"; then
    PASS=$((PASS + 1))
    echo "  PASS: send_notification exits 0 with empty token"
else
    FAIL=$((FAIL + 1))
    echo "  FAIL: send_notification exits 0 with empty token"
fi
if [[ ! -s "$CURL_LOG_FILE" ]]; then
    PASS=$((PASS + 1))
    echo "  PASS: curl not invoked when token empty"
else
    FAIL=$((FAIL + 1))
    echo "  FAIL: curl was invoked despite empty token"
fi

echo ""
echo "=== send_notification EchoBell POST (token configured) ==="
ECHOBELL_TOKEN="stub-token-abc123"
> "$CURL_LOG_FILE"
send_notification "Title" "Body" "my-project"
assert_contains "$CURL_LOG_FILE" "hook.echobell.one/t/stub-token-abc123" \
    "URL contains EchoBell token"
assert_contains "$CURL_LOG_FILE" "Content-Type: application/json" \
    "Content-Type header is application/json"
# POST is paired with -X; both should appear
assert_contains "$CURL_LOG_FILE" "-X" "curl uses -X flag"
assert_contains "$CURL_LOG_FILE" "POST" "HTTP method is POST"

echo ""
echo "=== send_notification: payload contains only title and body ==="
> "$CURL_LOG_FILE"
send_notification "TitleX" "BodyY" ""
# jq -n outputs compact JSON, e.g. {"title":"TitleX","body":"BodyY"}
assert_contains "$CURL_LOG_FILE" '"title":"TitleX"' "payload has title"
assert_contains "$CURL_LOG_FILE" '"body":"BodyY"' "payload has body"
assert_not_contains "$CURL_LOG_FILE" "group" "payload has no 'group' field"

echo ""
echo "=== send_notification: project name prefix applied to title ==="
> "$CURL_LOG_FILE"
send_notification "Alert" "msg" "my-project"
assert_contains "$CURL_LOG_FILE" '"title":"[my-project] Alert"' \
    "title prefixed with project name"

echo ""
echo "=== send_echobell_notification called directly ==="
> "$CURL_LOG_FILE"
send_echobell_notification "Direct Title" "Direct Body"
assert_contains "$CURL_LOG_FILE" '"title":"Direct Title"' "direct payload has title"
assert_contains "$CURL_LOG_FILE" '"body":"Direct Body"' "direct payload has body"
assert_not_contains "$CURL_LOG_FILE" "my-project" "direct call does not prepend project name"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━"
echo "Results: $PASS passed, $FAIL failed"
echo "━━━━━━━━━━━━━━━━━━━━━━"
[[ $FAIL -eq 0 ]] || exit 1
