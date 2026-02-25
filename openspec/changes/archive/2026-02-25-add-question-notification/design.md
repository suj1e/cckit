## Context

Claude Code 的 `Notification` hook 在 Claude 发送通知时触发。当 Claude 使用 AskUserQuestion 工具向用户提问时，可能会触发此 hook。

需要验证 AskUserQuestion 是否触发 Notification hook，以及输入 JSON 的格式。

## Goals / Non-Goals

**Goals:**
- 当 Claude 提问时发送通知到配置的通道
- 通知包含问题摘要
- 复用现有的通知基础设施

**Non-Goals:**
- 不在通知中提供回答功能
- 不修改其他 hook 的行为

## Decisions

### 1. Hook 类型

**决定**: 使用 `Notification` hook。

**理由**: 根据规范，Notification hook 在 Claude 发送通知时触发，AskUserQuestion 可能属于此类。

### 2. 脚本实现

**决定**: 创建 `notification.sh` 脚本，解析输入 JSON 并发送通知。

**输入格式**（待验证）:
```json
{
  "notification": {
    "type": "question",
    "title": "问题标题",
    "body": "问题描述"
  },
  "session_id": "..."
}
```

### 3. 通知格式

```
❓ Claude 提问

问题标题
```

### 4. 通知分组

使用新分组 `claude-question`，颜色使用蓝色。

## Risks / Trade-offs

**风险**: AskUserQuestion 可能不触发 Notification hook
→ **缓解**: 实现后测试，如果不触发则调研其他方案

**风险**: 输入 JSON 格式不确定
→ **缓解**: 实现时添加调试日志，捕获实际格式
