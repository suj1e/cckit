## Context

barnhk 的 Notification hook 在收到 Claude 发送的通知时，会通过 Bark/Discord/飞书 推送给用户。当前实现在 `permission_prompt` 类型时只显示固定的 "🔐 Permission required"，忽略了 JSON 输入中的 `message` 字段。

根据官方文档，Notification hook 的输入包含：
- `message`: 具体通知内容（如 "Claude needs your permission to use Bash"）
- `title`: 通知标题
- `notification_type`: 通知类型（如 `permission_prompt`, `question` 等）

**当前代码问题**（`notification.sh:23-30`）：
```bash
case "$NOTIFICATION_TYPE" in
    permission_prompt)
        NOTIF_BODY="🔐 Permission required"  # 问题：忽略 MESSAGE 字段
        ;;
    *)
        NOTIF_BODY="${MESSAGE:-Claude needs your attention}"
        ;;
esac
```

## Goals / Non-Goals

**Goals:**
- 在所有通知类型中显示 `message` 字段的具体内容
- 根据 `notification_type` 添加不同的图标前缀，便于快速识别
- 截取过长的消息保持通知简洁（限制 200 字符）

**Non-Goals:**
- 不修改通知渠道（Bark/Discord/飞书）的实现
- 不改变通知触发的时机或条件

## Decisions

### 1. 统一使用 MESSAGE 字段

**决定**: 移除 `case` 分支中对 `MESSAGE` 的忽略，所有类型都显示 `message` 字段。

**理由**:
- `message` 字段已经包含了用户需要知道的具体内容
- 不同类型通过图标区分即可，不需要改变内容显示逻辑

**替代方案**: 保留 `case` 分支但每个分支都使用 `$MESSAGE`
- 否决：增加代码复杂度，没有实际收益

### 2. 按类型添加图标前缀

**决定**: 使用图标前缀区分不同通知类型：
- `permission_prompt`: 🔐
- `question`: ❓
- 其他/未知: 🔔

**理由**:
- 图标提供视觉区分，用户一眼就能看出通知类型
- 不改变消息内容本身，只是添加前缀

### 3. 消息长度截断

**决定**: 截取消息前 200 字符，超出部分显示 "..."

**理由**:
- 某些工具输入（如长命令）可能导致消息过长
- 通知系统通常对长度有限制
- 200 字符足够传达核心信息

## Risks / Trade-offs

**Risk**: 消息截断可能丢失重要信息
→ **Mitigation**: 200 字符足够显示关键内容；用户可查看 Claude Code 终端获取完整信息

**Risk**: 图标在某些通知渠道可能显示异常
→ **Mitigation**: Bark、Discord、飞书 都支持 emoji，无需额外处理
