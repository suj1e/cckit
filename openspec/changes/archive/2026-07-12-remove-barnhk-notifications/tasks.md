# Tasks

## Phase 1: Remove notification code

- [x] 1.1 Delete `lib/notify.sh`, `lib/notification.sh`, `lib/transcript.sh`
- [x] 1.2 Delete `tests/test-notify.sh`
- [x] 1.3 Update `lib/common.sh` — remove notify/transcript source lines, remove `get_notification_mode()`, `get_notification_title()`, remove `notification` case from `dispatch_hook()`
- [x] 1.4 Update `lib/hooks.sh` — remove all `send_notification` calls, remove `hook_notification()` function
- [x] 1.5 Update `plugin.json` — remove `Notification` hook entry, add `"timeout": 10` to all remaining hooks
- [x] 1.6 Clean `lib/barnhk.env` — remove `ECHOBELL_TOKEN`, `TITLE_*`, `NOTIFICATION_*`, `DEBUG_ENABLED`

## Phase 2: Update standards

- [x] 2.1 Fix PreToolUse output field name: `denyReason` → `permissionDecisionReason`
- [x] 2.2 Add "zero side effects" best practice
- [x] 2.3 Add "set timeout" best practice
- [x] 2.4 Add network I/O warning to Notification chapter

## Phase 3: Verify

- [x] 3.1 Run `bash hooks/barnhk/tests/test-safety.sh` — all pass
- [x] 3.2 Run `bash hooks/barnhk/tests/test-hooks.sh` — all pass
