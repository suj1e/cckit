## Why

Currently, when barnhk encounters a command that requires manual approval, it only sends a notification. The user must be physically present at their computer to click "Allow" in the Claude CLI interface. This limits the ability to approve commands remotely while away from the desk.

By integrating with cplit (a remote approval service), users can approve or deny commands from their mobile device via Feishu, enabling true remote workflow control.

## What Changes

- Add `CPLIT_ENABLED` configuration option (default: `false`)
- Add `CPLIT_URL` configuration option for specifying the cplit server endpoint
- When cplit is enabled and a command requires manual approval:
  - Call cplit's `/request-approval` API with command and cwd
  - Block until cplit returns a decision (approve/deny)
  - Output the appropriate decision JSON to Claude CLI
- Fallback to local manual approval if cplit is disabled or unavailable

## Capabilities

### New Capabilities

- `cplit-integration`: Capability to integrate with cplit remote approval service for non-whitelisted commands

### Modified Capabilities

None - this is an optional enhancement that doesn't change existing behavior when disabled.

## Impact

- `hooks/barnhk/lib/barnhk.conf` - Add `CPLIT_ENABLED` and `CPLIT_URL` config options
- `hooks/barnhk/lib/common.sh` - Add `request_cplit_approval()` function
- `hooks/barnhk/lib/permission-request.sh` - Add cplit integration logic for manual approval flow
- External dependency: cplit server must be running and accessible
