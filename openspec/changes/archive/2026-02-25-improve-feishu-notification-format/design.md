## Context

当前 `send_feishu_notification()` 函数使用简单的标题+正文格式发送飞书卡片消息。各 hook 脚本传递的 `body` 参数是纯文本字符串，格式类似：

```
[BASH] Auto-approved
Cmd: git status
```

飞书支持更丰富的卡片元素，包括：
- `div` - 分段文本
- `hr` - 分隔线
- `markdown` - Markdown 格式
- `note` - 备注文本

本次改进旨在利用这些元素创建更清晰、更美观的通知卡片。

## Goals / Non-Goals

**Goals:**
- 为不同通知类型（permit/done/stop/idle）设计统一且美观的卡片布局
- 使用结构化字段展示关键信息（命令、路径、会话ID等）
- 保持与 Bark/Discord 通知接口的兼容性
- 支持可选的扩展字段

**Non-Goals:**
- 不改变通知触发逻辑
- 不修改 Bark 或 Discord 的通知格式
- 不添加新的通知类型

## Decisions

### 1. 通知接口扩展

**决定**: 保持现有 `send_notification <group> <title> <body>` 接口不变，在 `send_feishu_notification()` 内部解析 body 内容并构建结构化卡片。

**理由**:
- 避免修改所有 hook 脚本
- Bark 和 Discord 继续使用纯文本格式
- 飞书独享结构化展示

**备选方案**:
- 方案 B: 引入 `send_feishu_card()` 新函数，接受 JSON 参数 - 放弃，增加复杂度

### 2. Body 格式约定

**决定**: 使用简单的键值对格式，通过换行和冒号分隔：

```
[Label] Status
Key1: Value1
Key2: Value2
```

解析规则：
- 第一行作为主要状态描述（带 emoji）
- 后续 `Key: Value` 格式转为字段标签和内容
- 空行忽略

**理由**: 保持简单，无需修改现有 hook 脚本的 body 构建逻辑。

### 3. 卡片布局设计

**决定**: 使用以下布局结构：

```
┌────────────────────────────────┐
│ Header: 标题 (带颜色)           │
├────────────────────────────────┤
│ 📋 状态描述                     │
│                                │
│ ──────────────────────────────│
│ 📌 字段1                       │
│    值1                         │
│                                │
│ 📌 字段2                       │
│    值2                         │
├────────────────────────────────┤
│ footer: group 名称              │
└────────────────────────────────┘
```

**字段图标映射**:
- Cmd → ⌨️
- Path → 📁
- Session → 🔗
- Reason → 💡
- Tool → 🔧
- 默认 → 📌

### 4. 颜色方案

保持现有颜色映射不变：
| 分组 | 颜色 |
|------|------|
| claude-danger | red |
| claude-permit | green |
| claude-done | blue |
| claude-stop | orange |
| claude-idle | grey |

## Risks / Trade-offs

**风险**: Body 解析可能失败
→ **缓解**: 解析失败时回退到纯文本展示，保证通知不会丢失

**风险**: 多行值（如长命令）展示不佳
→ **缓解**: 超长内容截断处理，已在 truncate_string 中实现

**权衡**: 不使用飞书 Markdown 元素
→ 原因: div + note 元素兼容性更好，无需转义特殊字符
