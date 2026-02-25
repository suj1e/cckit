# Claude Code Hooks 规范文档

> 来源: https://code.claude.com/docs/en/hooks
>
> 本文档定义了 Claude Code hooks 的标准接口规范。开发 hooks 时必须严格遵守此规范。

## 概述

Hooks 允许你在特定事件发生时执行自定义脚本，用于：
- 自动审批安全操作
- 阻止危险命令
- 发送通知
- 记录操作日志

## 通用规范

### 脚本要求

- **解释器**: 使用 `#!/usr/bin/env bash` 以确保跨平台兼容性
- **输入**: JSON 格式，通过 stdin 传入
- **输出**: JSON 格式，输出到 stdout
- **错误信息**: 输出到 stderr

### 退出码

| 退出码 | 含义 |
|--------|------|
| `0` | 成功，允许操作继续 |
| `2` | 阻断性错误，阻止操作 |

> **重要**: 使用 `exit 2` 表示阻断，不要使用 `exit 1`

### JSON 解析

所有 hook 脚本必须使用 `jq` 解析 JSON 输入：

```bash
# 推荐的 JSON 解析方式
json_value() {
    local key="$1"
    jq -r "$key // empty" 2>/dev/null
}

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | json_value '.tool_name')
```

---

## Hook 类型

### PreToolUse

在工具执行之前触发，用于检测和阻止危险操作。

#### 输入 JSON

```json
{
  "tool_name": "Bash",
  "tool_input": {
    "command": "rm -rf /"
  },
  "tool_use_id": "toolu_01ABC123",
  "session_id": "sess_01XYZ789"
}
```

#### 输出 JSON（阻断时）

```json
{
  "hookSpecificOutput": {
    "permissionDecision": "deny",
    "denyReason": "Critical dangerous command detected: rm -rf /"
  }
}
```

#### 字段说明

| 字段 | 类型 | 说明 |
|------|------|------|
| `tool_name` | string | 工具名称（如 Bash, Read, Write） |
| `tool_input` | object | 工具输入参数 |
| `tool_use_id` | string | 工具调用唯一标识 |
| `session_id` | string | 会话标识 |

#### 输出字段

| 字段 | 类型 | 说明 |
|------|------|------|
| `hookSpecificOutput.permissionDecision` | string | 决策：`"allow"` 或 `"deny"` |
| `hookSpecificOutput.denyReason` | string | 阻断原因（deny 时必填） |

---

### PermissionRequest

当 Claude 请求权限时触发，用于自动审批安全操作。

#### 输入 JSON

```json
{
  "tool_name": "Bash",
  "tool_input": {
    "command": "git status"
  },
  "tool_use_id": "toolu_01ABC123",
  "session_id": "sess_01XYZ789"
}
```

#### 输出 JSON（自动批准）

```json
{
  "hookSpecificOutput": {
    "permissionDecision": "allow"
  }
}
```

#### 输出 JSON（不自动处理）

不输出任何内容，让用户手动审批。

---

### TaskCompleted

任务完成时触发。

#### 输入 JSON

```json
{
  "session_id": "sess_01XYZ789",
  "task": "Fix the bug in auth module"
}
```

---

### Stop

会话停止时触发（用户主动停止）。

#### 输入 JSON

```json
{
  "session_id": "sess_01XYZ789",
  "reason": "user_requested"
}
```

---

### SessionEnd

会话完全结束时触发。

#### 输入 JSON

```json
{
  "session_id": "sess_01XYZ789"
}
```

---

### TeammateIdle

队友 Agent 进入空闲状态时触发。

#### 输入 JSON

```json
{
  "session_id": "sess_01XYZ789",
  "agent_id": "agent_01ABC",
  "agent_name": "researcher"
}
```

---

## 其他 Hook 类型

以下 hook 类型在 Claude Code 中可用，但较少使用：

| Hook | 触发时机 |
|------|---------|
| `SessionStart` | 会话开始时 |
| `UserPromptSubmit` | 用户提交提示词时 |
| `PostToolUse` | 工具执行成功后 |
| `PostToolUseFailure` | 工具执行失败后 |
| `Notification` | Claude 发送通知时 |
| `SubagentStart` | 子 Agent 启动时 |
| `SubagentStop` | 子 Agent 停止时 |
| `ConfigChange` | 配置变更时 |
| `WorktreeCreate` | 创建 worktree 时 |
| `WorktreeRemove` | 删除 worktree 时 |
| `PreCompact` | 上下文压缩前 |

---

## 配置格式

Hooks 在 `settings.json` 中配置：

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": ["/path/to/pre-tool-use.sh"]
      }
    ],
    "PermissionRequest": [
      {
        "matcher": "Bash",
        "hooks": ["/path/to/permission-request.sh"]
      }
    ],
    "TaskCompleted": [
      {
        "hooks": ["/path/to/task-completed.sh"]
      }
    ],
    "Stop": [
      {
        "hooks": ["/path/to/stop.sh"]
      }
    ],
    "SessionEnd": [
      {
        "hooks": ["/path/to/session-end.sh"]
      }
    ],
    "TeammateIdle": [
      {
        "hooks": ["/path/to/teammate-idle.sh"]
      }
    ]
  }
}
```

---

## 最佳实践

1. **使用正确的字段名**: 始终使用 `tool_name` 和 `tool_input`，不要使用旧版字段名
2. **正确的退出码**: 阻断时使用 `exit 2`
3. **结构化输出**: 使用 `hookSpecificOutput` 格式输出决策
4. **错误处理**: 脚本应该有良好的错误处理，避免意外崩溃
5. **日志记录**: 将调试信息输出到 stderr，不要影响 stdout 的 JSON 输出
6. **幂等性**: Hook 应该是幂等的，多次执行不会产生副作用

---

## 示例脚本

### PreToolUse 示例

```bash
#!/usr/bin/env bash
# pre-tool-use.sh - 危险命令检测

set -e

# 读取输入
INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# 只检查 Bash 工具
if [[ "$TOOL_NAME" != "Bash" ]] || [[ -z "$COMMAND" ]]; then
    exit 0
fi

# 检测危险命令
if [[ "$COMMAND" =~ rm[[:space:]]+-rf[[:space:]]+(/|/\*) ]]; then
    echo '{"hookSpecificOutput":{"permissionDecision":"deny","denyReason":"Critical: rm -rf / is blocked"}}'
    exit 2
fi

# 允许
exit 0
```

### PermissionRequest 示例

```bash
#!/usr/bin/env bash
# permission-request.sh - 自动审批安全命令

set -e

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# 自动批准 git 命令
if [[ "$COMMAND" =~ ^git[[:space:]]+(status|log|diff) ]]; then
    echo '{"hookSpecificOutput":{"permissionDecision":"allow"}}'
    exit 0
fi

# 不自动处理，让用户决定
exit 0
```
