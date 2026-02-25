## Why

barnhk 目前只支持 Bark (iOS 推送) 通知。为了支持团队协作和多平台通知，需要添加 Discord Webhook 支持。

Discord Webhook 可以：
- 发送消息到 Discord 频道，供团队共享
- 支持富文本格式 (Embeds)
- 免费使用，无需额外服务

## What Changes

- 在 `common.sh` 中添加 `send_discord_notification()` 函数
- 在 `common.sh` 中添加 `send_notification()` 统一入口函数
- 更新所有 hook 脚本使用 `send_notification()` 替代 `send_bark_notification()`
- 扩展 `barnhk.conf` 配置文件添加 Discord 相关配置
- 更新 `README.md` 文档

## Capabilities

### New Capabilities

- `discord-notification`: Discord Webhook 通知功能，支持 Embed 富文本格式

### Modified Capabilities

(None - 这是新增功能)

## Impact

- 新增 Discord 通知功能，不影响现有 Bark 通知
- 用户可同时配置 Bark 和 Discord，或只配置其中一个
- Hook 脚本调用方式变更，但行为保持兼容
