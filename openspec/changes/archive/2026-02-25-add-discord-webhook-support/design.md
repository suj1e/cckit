## Context

barnhk 目前使用 `send_bark_notification()` 函数发送 Bark iOS 推送通知。需要扩展支持 Discord Webhook，同时保持现有功能不变。

### Discord Webhook API

```
POST https://discord.com/api/webhooks/{webhook_id}/{webhook_token}

{
  "embeds": [{
    "title": "标题",
    "description": "内容",
    "color": 5763719,
    "footer": {"text": "分组标识"}
  }]
}
```

## Goals / Non-Goals

**Goals:**
- 添加 Discord Webhook 通知支持
- 创建统一的通知入口函数 `send_notification()`
- 支持同时配置多个通知通道
- 支持按分组设置不同的 Embed 颜色

**Non-Goals:**
- 不修改现有的 Bark 通知实现
- 不支持 Discord 的按钮、选择框等交互组件
- 不支持 @mention 功能

## Decisions

### 1. 统一通知入口

**决定**: 创建 `send_notification()` 函数作为统一入口

**理由**:
- Hook 脚本只需调用一个函数
- 便于未来扩展其他通知通道
- 配置灵活，可以只启用需要的通道

### 2. Discord Embed 格式

**决定**: 使用 Discord Embed 格式而非纯文本

**理由**:
- Embed 显示更美观
- 支持颜色区分不同类型的通知
- 支持标题、描述、页脚结构化展示

### 3. 颜色配置

**决定**: 在配置文件中定义各分组的颜色值

| 分组 | 默认颜色 | 含义 |
|------|----------|------|
| claude-danger | 红色 (15548997) | 危险命令被阻断 |
| claude-permit | 绿色 (5763719) | 权限审批 |
| claude-done | 蓝色 (3066993) | 任务完成 |
| claude-stop | 橙色 (15105570) | 会话停止 |
| claude-idle | 灰色 (8421504) | 队友空闲 |

### 4. 函数签名

**决定**: 保持与 `send_bark_notification()` 相同的签名

```bash
send_notification <group> <title> <body>
send_discord_notification <group> <title> <body>
```

**理由**:
- 保持接口一致性
- Hook 脚本改动最小

## Risks / Trade-offs

**Discord API 限流**: Discord 有速率限制 (每分钟 30 次)
→ 缓解：barnhk 通知频率较低，不会触发限流

**网络延迟**: 两个通知通道可能增加延迟
→ 缓解：通知调用使用 `-m 3` 超时，且失败时静默处理
