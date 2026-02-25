## Context

barnhk hooks 在构建 Bark 通知内容时使用 `\n` 作为换行符，但在 Bash 中这是字面字符串，不是真正的换行符。

**当前代码示例**:
```bash
BODY="$TOOL_LABEL Auto-approved\nCmd: $TRUNCATED_CMD"
```

**问题**: 通知显示为 `[BASH] Auto-approved\nCmd: git status` 而非两行显示。

## Goals / Non-Goals

**Goals:**
- 修复所有 hook 脚本中的换行符问题
- 通知内容正确显示为多行格式

**Non-Goals:**
- 不修改通知逻辑或内容
- 不添加新功能

## Decisions

### 使用 `$'\n'` 语法

**决定**: 将 `\n` 替换为 `$'\n'`

**理由**:
- `$'\n'` 是 Bash 的 ANSI-C 引用语法，生成真正的换行符
- 兼容 Bash 3.0+，符合项目的最低 Bash 版本要求
- 简单直接，无需额外函数或复杂逻辑

**修复方式**:
```bash
# 修复前
BODY="$BODY\nSession: $SHORT_SESSION"

# 修复后
BODY="$BODY"$'\n'"Session: $SHORT_SESSION"
```

## Risks / Trade-offs

无明显风险。这是纯 bug 修复，不影响任何功能逻辑。
