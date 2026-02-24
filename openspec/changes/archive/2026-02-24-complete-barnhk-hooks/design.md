## Context

barnhk is a Claude Code hooks toolkit that provides safety and notification features. Currently only a README.md exists without implementation. The hooks need to integrate with Claude Code's hook system which passes JSON input via stdin.

Claude Code hooks run as shell scripts that:
- Receive JSON input via stdin
- Exit with code 0 to allow, non-zero to block
- Can output JSON to stdout for certain hooks (e.g., PermissionRequest can auto-approve)

## Goals / Non-Goals

**Goals:**
- Implement all three hook types: PreToolUse, PermissionRequest, TaskCompleted
- Provide dangerous command detection with severity levels (Critical, High, Medium)
- Auto-approve common safe commands (git, npm, gradle, file operations)
- Send Bark notifications for permission requests, danger alerts, and task completion
- Create install/uninstall scripts for easy setup
- Support configurable settings via config file

**Non-Goals:**
- GUI configuration interface
- Notification services other than Bark
- Persistent rule updates without config file editing
- User authentication for Bark server

## Decisions

### D1: Shell Script Implementation
**Decision:** Use pure bash scripts for maximum compatibility
**Rationale:** No external dependencies, works on all Unix systems, matches Claude Code's hook interface

### D2: JSON Processing with jq
**Decision:** Require jq for JSON parsing
**Rationale:** Claude Code hooks pass JSON via stdin. jq is widely available and handles JSON robustly. Will check for jq availability in install script.

### D3: Configuration File Format
**Decision:** Use simple KEY=VALUE config file (barnhk.conf)
**Rationale:** Easy to edit, source in shell scripts, no additional parsing needed

### D4: Dangerous Command Detection Strategy
**Decision:** Pattern-based detection with severity levels
**Rationale:**
- Critical patterns: rm -rf /, dd to disk, mkfs (always block)
- High patterns: sudo, curl | bash, chmod 777 (block)
- Medium patterns: nc -l, kill -9 -1 (allow, no warning)

### D5: Bark Notification Groups
**Decision:** Use three notification groups for different event types
**Rationale:** iOS notification grouping allows users to distinguish urgency by sound and group:
- `claude-danger`: alarm sound for blocked commands
- `claude-permit`: bell sound for pending approvals
- `claude-done`: glass sound for completion

### D6: Hook Script Structure
**Decision:** Each hook is a standalone script that sources shared functions
**Rationale:** Easier maintenance, shared logic in common.sh, clear separation of concerns

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| jq not installed | install.sh checks and warns user |
| Bark server unreachable | Notification failures are silently ignored, hooks continue |
| BARK_SERVER_URL not configured | Notifications are skipped, auto-approval still works |
| Config file permissions | install.sh sets appropriate permissions (600) |
