## Why

barnhk 已支持 Bark (iOS) 和 Discord Webhook 通知。为了支持国内团队协作场景，需要添加飞书 Webhook 支持。

飞书在国内企业中使用广泛，Webhook 通知可以：
- 发送消息到飞书群聊，供团队共享
- 支持富文本卡片消息
- 国内网络访问稳定，无需代理

## What Changes

- 在 `common.sh` 中添加 `send_feishu_notification()` 函数
- 在 `send_notification()` 中调用飞书通知
- 扩展 `barnhk.conf` 配置文件添加飞书相关配置
- 更新 `README.md` 文档

## Capabilities

### New Capabilities

- `feishu-notification`: 飞书 Webhook 通知功能，支持卡片消息格式

### Modified Capabilities

(None)

## Impact

- 新增飞书通知功能，不影响现有 Bark 和 Discord 通知
- 用户可同时配置多个通知通道
