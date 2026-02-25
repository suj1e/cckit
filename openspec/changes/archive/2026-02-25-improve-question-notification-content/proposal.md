## Why

当 Claude 需要用户输入或权限确认时，barnhk 发送的通知内容过于笼统。根据官方文档，Notification hook 输入包含 `message` 字段（如 "Claude needs your permission to use Bash"），但当前代码在 `permission_prompt` 类型时只显示 "🔐 Permission required"，忽略了具体内容。用户无法从通知中区分具体是什么问题。

## What Changes

- 修改 `notification.sh`，在所有通知类型中显示 `message` 字段内容
- 根据 `notification_type` 添加不同图标前缀
- 截取长消息保持通知简洁

## Capabilities

### New Capabilities

- `question-notification-content`: 优化 Claude Question 通知内容，显示 `message` 字段的具体内容

### Modified Capabilities

None

## Impact

- `hooks/barnhk/lib/notification.sh`: 修改通知内容构建逻辑，显示 message 字段
- `standards/hooks/claude-code-hooks.md`: 更新 Notification hook 文档，补充完整输入字段
