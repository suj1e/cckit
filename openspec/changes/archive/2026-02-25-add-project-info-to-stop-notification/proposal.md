## Why

当 Claude 会话停止时，barnhk 发送的通知只显示 Session ID，用户无法从通知中识别是哪个项目的会话停止了。通知内容不够直观，需要点进去才能知道详情。

## What Changes

- 修改 `stop.sh`，从输入 JSON 中提取 `cwd` 字段，显示项目名称（目录名）
- 通知内容格式：项目名 + 会话 ID + 停止原因

## Capabilities

### New Capabilities

- `stop-notification-project-info`: Stop 通知显示项目信息

### Modified Capabilities

None

## Impact

- `hooks/barnhk/lib/stop.sh`: 添加项目名称提取和显示逻辑
