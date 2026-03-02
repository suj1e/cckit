## 1. Update Card Layout

- [x] 1.1 Update `sendApprovalCard()` in `/opt/dev/apps/cplit/src/services/feishu.ts` - command field `is_short: false`, add icons
- [x] 1.2 Update `updateCardMessage()` in `/opt/dev/apps/cplit/src/services/feishu.ts` - add cwd parameter, same layout with directory
- [x] 1.3 Update `sendTimeoutNotification()` in `/opt/dev/apps/cplit/src/services/feishu.ts` - add cwd parameter, same layout with directory

## 2. Update Callers

- [x] 2.1 Update `routes/approval.ts` to pass `cwd` to `updateCardMessage()` on approve/deny/timeout

## 3. Rebuild and Deploy

- [x] 3.1 Rebuild cplit (`pnpm build`)
- [x] 3.2 Redeploy cplit Docker container
- [x] 3.3 Test card layout by sending approval request and checking result cards
