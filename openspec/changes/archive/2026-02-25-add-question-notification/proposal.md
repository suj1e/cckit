## Why

当 Claude Code 使用 AskUserQuestion 工具向用户提问时，用户可能不在终端前，无法及时看到问题。需要发送通知提醒用户有待回答的问题。

## What Changes

- 添加 `Notification` hook 监听器
- 当 Claude 提问时发送飞书/Bark/Discord 通知
- 通知内容包含问题摘要

## Capabilities

### New Capabilities

- `question-notification`: Claude 提问时发送通知的能力

### Modified Capabilities

无

## Impact

- `hooks/barnhk/lib/notification.sh` - 新增 hook 脚本
- `hooks/barnhk/install.sh` - 添加 Notification hook 配置
- `hooks/barnhk/lib/barnhk.conf` - 添加新通知标题配置
