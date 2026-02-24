## 1. Setup and Shared Components

- [x] 1.1 Create `hooks/barnhk/common.sh` with shared functions (JSON parsing, Bark notification sender, config loader)
- [x] 1.2 Create `hooks/barnhk/barnhk.conf` configuration file with default settings (BARK_SERVER_URL, SAFE_COMMANDS, notification titles)

## 2. Dangerous Command Protection

- [x] 2.1 Implement critical-level command detection patterns (rm -rf /, dd to disk, mkfs)
- [x] 2.2 Implement high-level command detection patterns (sudo, curl | bash, chmod 777)
- [x] 2.3 Implement medium-level command detection patterns (nc -l, kill -9 -1) - allow without blocking
- [x] 2.4 Create `hooks/barnhk/pre-tool-use.sh` hook script with pattern matching and blocking logic

## 3. Safe Command Auto-Approval

- [x] 3.1 Define git command whitelist patterns
- [x] 3.2 Define package manager whitelist patterns (npm, pnpm, yarn, pip, gradle, mvn)
- [x] 3.3 Define file operation whitelist patterns (ls, cat, grep, find, head, tail)
- [x] 3.4 Create `hooks/barnhk/permission-request.sh` hook script with auto-approval logic
- [x] 3.5 Implement JSON output format for Claude Code approval response

## 4. Bark Notifications

- [x] 4.1 Implement send_bark_notification function with group and sound support
- [x] 4.2 Add notification support to permission-request.sh for auto-approval events
- [x] 4.3 Create `hooks/barnhk/task-completed.sh` hook script for task completion notifications
- [x] 4.4 Implement notification grouping (claude-danger, claude-permit, claude-done)

## 5. Installation Scripts

- [x] 5.1 Create `hooks/barnhk/install.sh` with dependency check (jq), config setup, and settings.json modification
- [x] 5.2 Create `hooks/barnhk/uninstall.sh` to remove hooks from settings.json
- [x] 5.3 Make all shell scripts executable
