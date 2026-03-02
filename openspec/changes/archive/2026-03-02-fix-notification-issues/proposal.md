## Why

Two notification-related issues are affecting user experience:

1. **barnhk title inaccuracy**: The Notification hook uses `TITLE_QUESTION` ("❓ Claude Question") for all notification types, including `idle_prompt` which is not a question but a waiting state. This confuses users who see "Question" for notifications that don't require a response.

2. **cplit Feishu card content missing**: The cplit remote approval service sends Feishu interactive cards with incorrect `fields` format. The card shows title and buttons but the content fields (command, cwd, requestId) don't render due to missing `text` wrapper and `is_short` property.

## What Changes

### barnhk Changes
- Add `TITLE_IDLE_PROMPT` configuration option (e.g., "⏳ Claude Waiting")
- Modify `notification.sh` to select title based on `notification_type`
- Use `TITLE_QUESTION` for `question` type, `TITLE_IDLE_PROMPT` for `idle_prompt` type

### cplit Changes
- Fix `fields` format in `feishu.ts` to match Feishu card specification
- Add `text` wrapper around field content
- Add `is_short` property for layout control
- Affects 3 functions: `sendApprovalCard()`, `updateCardMessage()`, `sendTimeoutNotification()`

## Capabilities

### New Capabilities

- `notification-type-titles`: Support for different notification titles based on notification type in barnhk Notification hook

### Modified Capabilities

- `notification-transcript-extraction`: Extend to support type-specific title selection (previous change only added content extraction and mode handling)

## Impact

**barnhk (cckit repo)**:
- `hooks/barnhk/lib/barnhk.conf` - Add `TITLE_IDLE_PROMPT` config
- `hooks/barnhk/lib/notification.sh` - Add title selection logic

**cplit (separate repo)**:
- `src/services/feishu.ts` - Fix fields format in 3 card-sending functions
