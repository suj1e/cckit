## Why

目前只有 Stop hook 的通知显示项目名称，其他通知（Notification、SessionEnd、TeammateIdle）都没有项目信息。用户收到通知时无法快速识别是哪个项目的通知，需要点进去查看详情才能知道。

## What Changes

- 统一所有通知的项目信息显示方式
- 在通知标题中添加项目名称前缀，格式：`[项目名] 原标题`
- 修改 `common.sh` 中的 `send_notification` 函数，统一处理项目名
- 移除 `stop.sh` 中单独的项目名处理逻辑（避免重复显示）

**修改后的通知标题示例：**
```
[cckit] Claude Session Ended
[cckit] Claude Notification
[cckit] Claude Stopped
```

## Capabilities

### New Capabilities

- `notification-project-prefix`: 通知标题统一添加项目名前缀

### Modified Capabilities

- `stop-notification-project-info`: 移除通知体中的项目名显示（改为标题前缀）

## Impact

- `hooks/barnhk/lib/common.sh`: 修改 `send_notification` 函数
- `hooks/barnhk/lib/stop.sh`: 移除单独的项目名处理逻辑
