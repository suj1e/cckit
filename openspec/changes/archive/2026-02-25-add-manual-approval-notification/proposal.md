## Why

When a command is not in the whitelist and requires manual approval, no Bark notification is sent. Users may not realize Claude is waiting for their confirmation, especially when working in another window or on another device.

## What Changes

- Add Bark notification when a command requires manual approval (not in whitelist)
- Update README.md to document all notification scenarios

## Capabilities

### New Capabilities

(None)

### Modified Capabilities

- `safe-command-auto-approval`: Add notification for manual approval scenario

## Impact

- `lib/permission-request.sh` - add notification before exiting for non-whitelisted commands
- `README.md` - document notification triggers
