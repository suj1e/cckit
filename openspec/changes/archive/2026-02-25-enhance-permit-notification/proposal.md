## Why

Bark 通知 `claude-permit` 信息不够详细，只显示 "Manual approval: $COMMAND"，用户无法从通知中判断具体要审核什么内容，需要打开终端查看详情。这降低了通知的实用性。

## What Changes

- 增强 `claude-permit` 通知内容，包含更多上下文信息
- 添加工具类型（Bash、Read、Write 等）
- 添加会话 ID 或任务描述（如果可用）
- 区分自动批准和手动审批的通知内容
- 通知内容截断处理，避免过长命令导致通知难以阅读

## Capabilities

### New Capabilities

- `detailed-permit-notification`: 权限请求通知包含完整的上下文信息

### Modified Capabilities

- None

## Impact

- `hooks/barnhk/lib/permission-request.sh` - 主要修改文件
- `hooks/barnhk/lib/common.sh` - 可能需要更新 `send_bark_notification` 函数
