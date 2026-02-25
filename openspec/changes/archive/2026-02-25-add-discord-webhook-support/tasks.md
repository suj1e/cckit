## 1. Update common.sh

- [x] 1.1 Add `send_discord_notification()` function with Embed support
- [x] 1.2 Add `send_notification()` unified entry function
- [x] 1.3 Add color mapping for notification groups

## 2. Update configuration

- [x] 2.1 Add Discord configuration options to `barnhk.conf`

## 3. Update hook scripts

- [x] 3.1 Update `permission-request.sh` to use `send_notification()`
- [x] 3.2 Update `pre-tool-use.sh` to use `send_notification()`
- [x] 3.3 Update `task-completed.sh` to use `send_notification()`
- [x] 3.4 Update `stop.sh` to use `send_notification()`
- [x] 3.5 Update `session-end.sh` to use `send_notification()`
- [x] 3.6 Update `teammate-idle.sh` to use `send_notification()`

## 4. Update documentation

- [x] 4.1 Update `README.md` with Discord configuration instructions

## 5. Install and verify

- [x] 5.1 Reinstall barnhk hooks locally
