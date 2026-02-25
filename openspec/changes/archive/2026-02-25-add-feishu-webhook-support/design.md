## Context

barnhk 已有 `send_notification()` 统一入口，支持 Bark 和 Discord。现在需要添加飞书 Webhook 支持。

### 飞书 Webhook API

```
POST https://open.feishu.cn/open-apis/bot/v2/hook/{hook_id}

{
  "msg_type": "interactive",
  "card": {
    "header": {
      "title": { "tag": "plain_text", "content": "标题" },
      "template": "blue"
    },
    "elements": [
      { "tag": "div", "text": { "tag": "plain_text", "content": "内容" } }
    ]
  }
}
```

## Goals / Non-Goals

**Goals:**
- 添加飞书 Webhook 通知支持
- 使用飞书卡片消息格式
- 支持按分组设置不同的卡片颜色

**Non-Goals:**
- 不支持飞书按钮、表单等交互组件
- 不支持 @用户 功能

## Decisions

### 1. 消息格式

**决定**: 使用飞书卡片消息 (interactive) 格式

**理由**:
- 卡片消息显示更美观
- 支持标题、内容、颜色结构化展示
- 与 Discord Embed 风格一致

### 2. 颜色配置

**决定**: 使用飞书卡片模板颜色

| 分组 | 模板颜色 | 含义 |
|------|----------|------|
| claude-danger | red | 危险命令被阻断 |
| claude-permit | green | 权限审批 |
| claude-done | blue | 任务完成 |
| claude-stop | orange | 会话停止 |
| claude-idle | grey | 队友空闲 |

### 3. 函数签名

**决定**: 保持与其他通知函数相同的签名

```bash
send_feishu_notification <group> <title> <body>
```

## Risks / Trade-offs

**飞书 API 变更**: 飞书可能更新 API
→ 缓解：使用稳定的 Webhook v2 API

**网络延迟**: 三个通知通道可能增加延迟
→ 缓解：通知调用使用超时机制，失败时静默处理
