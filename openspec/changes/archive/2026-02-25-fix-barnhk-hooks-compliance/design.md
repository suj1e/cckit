## Context

barnhk 是 Claude Code 的 hooks 增强工具包，当前实现基于早期理解的 hooks 接口。经过与官方文档对比，发现多处不兼容问题需要修复。

**官方 Hooks 接口规范：**
- 输入 JSON 字段：`tool_name`, `tool_input`, `tool_use_id`, `session_id`
- 退出码：`0` = 允许，`2` = 阻断
- PreToolUse 阻断输出：使用 `hookSpecificOutput.permissionDecision`

## Goals / Non-Goals

**Goals:**
- 修复所有 JSON 路径错误，确保与官方规范兼容
- 规范化退出码使用
- 使用结构化 JSON 输出格式
- 新增 SessionEnd hook 提供会话结束通知

**Non-Goals:**
- 不添加其他新 hooks（如 Notification、PostToolUse 等）
- 不改变现有的白名单逻辑和危险命令检测逻辑
- 不修改 Bark 通知的分组和声音配置

## Decisions

### 1. JSON 路径修复

| 文件 | 当前路径 | 修正路径 |
|------|---------|---------|
| pre-tool-use.sh | `.tool` | `.tool_name` |
| pre-tool-use.sh | `.input.command` | `.tool_input.command` |
| permission-request.sh | `.permission.name` | `.tool_name` |
| permission-request.sh | `.permission.command` | `.tool_input.command` |
| permission-request.sh | `.permission.path` | `.tool_input.path` |

**理由**：官方文档明确定义了输入 JSON 结构。

### 2. 退出码规范化

```bash
# 当前（错误）
exit 1  # 用于阻断

# 修正后
exit 2  # 用于阻断性错误
exit 0  # 用于允许
```

**理由**：官方规范定义 exit 2 为阻断性错误，exit 1 可能导致不明确的行为。

### 3. PreToolUse 输出格式

```bash
# 当前（不完整）
echo "BLOCKED: ..." >&2
exit 1

# 修正后（结构化）
echo '{"hookSpecificOutput":{"permissionDecision":"deny","denyReason":"..."}}'
exit 2
```

**理由**：官方推荐使用结构化 JSON 输出，便于 Claude Code 解析和展示。

### 4. SessionEnd Hook 实现

创建 `session-end.sh`，与其他 hooks 结构保持一致：
- 读取 stdin JSON 输入
- 提取 session_id
- 发送 Bark 通知到 `claude-stop` 分组

**理由**：SessionEnd 在会话完全结束时触发，比 TaskCompleted 更适合作为最终通知。

### 5. 规范文档目录结构

```
standards/
└── hooks/
    └── claude-code-hooks.md   # Claude Code 官方 hooks 规范
```

**理由**：
- `standards/` 目录用于存放各类标准规范文档
- 与 `openspec/`（变更管理）区分开，避免混淆
- 后续可扩展其他规范（如 `standards/skills/` 等）

## Risks / Trade-offs

| 风险 | 缓解措施 |
|------|---------|
| 修改后 hooks 不工作 | 修改前备份，修改后测试验证 |
| JSON 路径修复影响其他逻辑 | 只修改解析部分，保持业务逻辑不变 |
| SessionEnd 与 Stop hook 功能重叠 | 两者使用相同分组，用户可选择启用 |
