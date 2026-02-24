## Why

The barnhk hooks directory only contains a README.md without actual implementation. Users cannot use the safety and notification features described in the documentation. Implementing these hooks will provide dangerous command protection, automatic approval for safe commands, and Bark push notifications for Claude Code events.

## What Changes

- Implement `PreToolUse` hook script for dangerous command detection and blocking
- Implement `PermissionRequest` hook script for safe command auto-approval and Bark notifications
- Implement `TaskCompleted` hook script for task completion notifications
- Create `install.sh` script to configure hooks in Claude Code settings
- Create `uninstall.sh` script to remove hooks from Claude Code settings
- Add configuration file for customizing Bark server URL and whitelist commands

## Capabilities

### New Capabilities

- `dangerous-command-protection`: Detects and blocks dangerous shell commands (rm -rf /, sudo, curl | bash, etc.) before execution
- `safe-command-auto-approval`: Automatically approves common safe commands (git, npm, gradle, etc.) without user confirmation
- `bark-notification`: (Optional) Sends push notifications to iOS devices via Bark API when configured

### Modified Capabilities

(None - this is a new feature implementation)

## Impact

- Files created in `hooks/barnhk/`:
  - `pre-tool-use.sh` - PreToolUse hook script
  - `permission-request.sh` - PermissionRequest hook script
  - `task-completed.sh` - TaskCompleted hook script
  - `install.sh` - Installation script
  - `uninstall.sh` - Uninstallation script
  - `barnhk.conf` - Configuration file
- Modifies Claude Code settings (`~/.claude/settings.json`) during installation
- Bark notifications optional - requires BARK_SERVER_URL configuration to enable
