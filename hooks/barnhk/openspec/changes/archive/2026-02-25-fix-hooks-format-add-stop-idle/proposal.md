## Why

The current hook configuration format in install.sh is incorrect - it uses `matcher` as an empty object `{}` instead of a string regex. This causes Claude Code to fail with "Expected object, but received string" errors. Additionally, the hooks lack notification support for Stop (when Claude stops) and TeammateIdle (when teammates go idle) events.

## What Changes

- **Fix hook format**: Change `matcher` from object `{}` to string regex `"Bash"` for PreToolUse and PermissionRequest hooks
- **Add Stop hook**: Create `stop.sh` script and register it in settings for session end notifications
- **Add TeammateIdle hook**: Create `teammate-idle.sh` script and register it for teammate idle notifications
- **Update install.sh**: Fix JSON format and add new hooks
- **Update uninstall.sh**: Handle removal of new hooks

## Capabilities

### New Capabilities
- `stop-notification`: Send Bark notification when Claude session stops
- `teammate-idle-notification`: Send Bark notification when teammates go idle

### Modified Capabilities
- `safe-command-auto-approval`: Fix hook configuration format (matcher as string regex)

## Impact

- `hooks/barnhk/install.sh` - Fix JSON format, add Stop and TeammateIdle hooks
- `hooks/barnhk/uninstall.sh` - Handle new hook types
- `hooks/barnhk/lib/stop.sh` - New script for Stop hook
- `hooks/barnhk/lib/teammate-idle.sh` - New script for TeammateIdle hook
- `~/.claude/settings.json` - Updated hook configuration format
