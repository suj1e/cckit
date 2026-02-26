## Context

当前 `permission-request.sh` 使用单一的 notification group `claude-permit` 处理所有权限请求通知，无论是自动审批还是需要手动审批。

颜色映射在 `common.sh` 的 `get_discord_color()` 和 `get_feishu_color()` 函数中定义。

## Goals / Non-Goals

**Goals:**
- 通过颜色区分 auto-approved 和 manual approval 通知
- 为 manual approval 提供更醒目的标题
- 保持 Bark (iOS) 通知的一致性（Bark 不支持颜色）

**Non-Goals:**
- 不修改其他 hook 的通知逻辑
- 不修改 Discord/Feishu 的通知结构

## Decisions

### Decision 1: Group 命名

**选择**: 使用 `claude-auto-permit` 和 `claude-manual-permit`

**理由**:
- 语义清晰，一看就知道是自动还是手动
- 保持 `claude-` 前缀一致性
- 中间部分描述类型（auto/manual）
- 后缀 `permit` 与现有 `claude-permit` 保持关联

### Decision 2: 颜色选择

**选择**:
- `claude-auto-permit`: 绿色 (5763719) - 保持现有颜色
- `claude-manual-permit`: 黄色 (16776960) 或橙色 (15105570)

**理由**:
- 绿色表示"通过/安全"，符合 auto-approved 的含义
- 黄色/橙色表示"警告/需要关注"，符合 manual approval 的含义
- 使用现有 Discord 颜色值保持一致性

### Decision 3: 标题选择

**选择**:
- Auto-approved: `🔔 Claude Permit` (保持不变)
- Manual approval: `🔐 Claude Approval`

**理由**:
- `🔐` emoji 暗示需要解锁/授权
- `Approval` 比 `Permit` 更强调需要审批动作

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| Bark 不支持颜色区分 | 通过不同标题区分，Bark 用户仍能通过标题区分 |
| 新增配置项 | TITLE_APPROVAL 有合理默认值，用户无需手动配置 |
