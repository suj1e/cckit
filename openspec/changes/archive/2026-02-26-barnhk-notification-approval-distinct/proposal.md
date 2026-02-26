## Why

当前 permission-request.sh 在两种情况下使用相同的通知标题（🔔 Claude Permit）：
1. 命令被自动审批通过
2. 命令需要用户手动审批

用户无法通过通知标题或颜色快速区分这两种情况，需要点开通知查看 Body 内容才能知道。

## What Changes

- 将 auto-approved 和 manual approval 的通知分离为不同的 group
- 为 manual approval 添加新的标题 `🔐 Claude Approval`
- 使用不同颜色区分：
  - Auto-approved: 绿色
  - Manual approval: 黄色/橙色

## Capabilities

### New Capabilities

无新 capability。

### Modified Capabilities

- `safe-command-auto-approval`: 添加通知类型区分的要求（auto-approved vs manual approval 使用不同的 group、标题和颜色）

## Impact

- **修改文件**：
  - `hooks/barnhk/lib/barnhk.conf` - 添加 `TITLE_APPROVAL`
  - `hooks/barnhk/lib/common.sh` - 添加 `claude-auto-permit` 和 `claude-manual-permit` 颜色映射
  - `hooks/barnhk/lib/permission-request.sh` - 使用新的 group 和 title
- **影响功能**：权限请求通知
- **向后兼容**：完全兼容，无 breaking changes
