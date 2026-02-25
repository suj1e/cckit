## Context

当前 barnhk 的 `send_notification` 函数接收 `group`、`title`、`body` 三个参数，发送通知到 Bark/Discord/飞书。只有 Stop hook 在 body 中显示项目名，其他通知都没有项目信息。

各 hook 调用 `send_notification` 的位置：
- `stop.sh` - 有 cwd，已实现项目名显示
- `notification.sh` - 有 cwd
- `session-end.sh` - 有 cwd
- `teammate-idle.sh` - 有 cwd

## Goals / Non-Goals

**Goals:**
- 统一所有通知的项目信息显示方式
- 项目名显示在标题前缀，格式：`[项目名] 原标题`
- 修改 `common.sh` 的 `send_notification` 函数支持可选项目名参数
- 各 hook 传递 cwd，由 `send_notification` 统一提取和显示项目名

**Non-Goals:**
- 不修改通知 body 的格式
- 不改变通知触发逻辑

## Decisions

### 1. 项目名显示在标题前缀

**决定**: 在通知标题前添加 `[项目名]` 前缀

**理由**:
- 标题是通知最显眼的部分，用户一眼就能看到项目名
- body 内容保持原有结构，不影响可读性
- 移动端推送通知通常只显示标题，项目名在标题中更有效

**替代方案**: 在 body 第一行显示项目名
- 否决：移动端推送通知可能不显示 body，用户看不到项目名

### 2. 修改 send_notification 函数签名

**决定**: 添加第四个可选参数 `project_name`

```bash
send_notification() {
    local group="$1"
    local title="$2"
    local body="$3"
    local project_name="${4:-}"

    # Prepend project name to title if provided
    if [[ -n "$project_name" ]]; then
        title="[$project_name] $title"
    fi
    ...
}
```

**理由**:
- 向后兼容：不传第四个参数时行为不变
- 职责清晰：`send_notification` 负责格式化，hook 负责提供数据

**替代方案**: 在每个 hook 中自行格式化标题
- 否决：重复代码，维护成本高

### 3. 各 hook 从 cwd 提取项目名并传递

**决定**: 各 hook 使用 `basename "$CWD"` 提取项目名，传递给 `send_notification`

**理由**:
- cwd 是 Claude Code hooks 的标准输入字段
- 各 hook 已有读取 cwd 的能力
- 提取逻辑简单（一行 basename）

## Risks / Trade-offs

**Risk**: 标题长度可能过长
→ **Mitigation**: 项目名通常较短（目录名），影响有限

**Risk**: 某些 hook 可能没有 cwd 字段
→ **Mitigation**: 参数可选，不传则不显示项目名
