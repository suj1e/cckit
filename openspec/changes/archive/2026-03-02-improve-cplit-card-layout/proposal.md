## Why

Current cplit Feishu approval card layout looks cramped and hard to read:
- All three fields (command, directory, request ID) are squeezed in one row with `is_short: true`
- No visual hierarchy - everything looks equally important
- No icons to help quick scanning
- **Result cards (approved/denied) missing directory info** - only shows command and time, inconsistent with timeout card

## What Changes

- Command field takes full width (`is_short: false`) since it's the most important info
- Directory and Request ID/Time share a row (`is_short: true`)
- Add icons for visual distinction: ⌨️ for command, 📁 for directory, 🕐 for time
- Improve markdown formatting for better readability
- **Add directory field to result cards** (approved/denied/timeout) for consistency

## Capabilities

### New Capabilities

- `feishu-approval-card-layout`: Visual layout requirements for cplit Feishu approval cards

### Modified Capabilities

(none - this is a new capability)

## Impact

**cplit (separate repo)**:
- `src/services/feishu.ts` - Update `sendApprovalCard()`, `updateCardMessage()`, `sendTimeoutNotification()` functions
