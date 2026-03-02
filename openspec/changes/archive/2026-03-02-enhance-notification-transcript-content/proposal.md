## Why

当前 Notification hook 发送的通知内容使用通用文案（如 "Claude is waiting for your input"），用户无法从通知中得知具体是什么问题，需要打开终端查看。同时，`permission_prompt` 类型的通知与 `permission-request.sh` 发送的通知重复。

## What Changes

- 从 transcript 文件提取最后一条 assistant 的 text 消息，作为通知的具体内容
- 添加配置项控制各 notification_type 的处理方式：`skip`（跳过）、`default`（通用文案）、`transcript`（提取具体内容）
- 默认跳过 `permission_prompt` 类型，避免与 `permission-request.sh` 重复
- 使用 `sessionId` 验证提取的内容属于当前会话，防止串会话
- 提取失败时回退到通用 message

## Capabilities

### New Capabilities

- `notification-transcript-extraction`: 从 transcript 提取具体通知内容的能力

### Modified Capabilities

- `question-notification-content`: 扩展需求，支持从 transcript 提取内容，添加类型配置

## Impact

- `hooks/barnhk/lib/notification.sh` - 主要修改
- `hooks/barnhk/lib/barnhk.conf` - 添加配置项
- `hooks/barnhk/lib/common.sh` - 可能添加提取函数
