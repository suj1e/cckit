## 1. barnhk Title Configuration

- [x] 1.1 Add `TITLE_IDLE_PROMPT` configuration to `hooks/barnhk/lib/barnhk.conf` with default value "⏳ Claude Waiting"

## 2. barnhk Title Selection Logic

- [x] 2.1 Add `get_notification_title()` function to `hooks/barnhk/lib/common.sh` that maps notification types to title variables
- [x] 2.2 Update `hooks/barnhk/lib/notification.sh` to use `get_notification_title()` instead of hardcoded `TITLE_QUESTION`

## 3. cplit Feishu Card Fix

- [x] 3.1 Fix `fields` format in `/opt/dev/apps/cplit/src/services/feishu.ts` `sendApprovalCard()` function
- [x] 3.2 Fix `fields` format in `/opt/dev/apps/cplit/src/services/feishu.ts` `updateCardMessage()` function
- [x] 3.3 Fix `fields` format in `/opt/dev/apps/cplit/src/services/feishu.ts` `sendTimeoutNotification()` function

## 4. Verification

- [x] 4.1 Reinstall barnhk plugin and verify TITLE_IDLE_PROMPT works
- [x] 4.2 Test cplit Feishu card displays fields correctly (requires CPLIT_ENABLED=true)
