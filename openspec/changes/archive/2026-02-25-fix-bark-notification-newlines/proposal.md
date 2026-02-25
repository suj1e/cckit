## Why

Bark 通知内容中的换行符 `\n` 显示为字面字符而非实际换行，导致通知内容格式混乱、可读性差。

问题原因：Bash 中使用 `BODY="$BODY\nText"` 语法时，`\n` 被视为字面字符串而非换行符。需要使用 `$'\n'` 语法才能生成真正的换行。

## What Changes

- 修复所有 barnhk hook 脚本中的换行符问题
- 将 `\n` 替换为 `$'\n'` 以生成真正的换行符
- 涉及文件：
  - `hooks/barnhk/lib/permission-request.sh`
  - `hooks/barnhk/lib/session-end.sh`
  - `hooks/barnhk/lib/stop.sh`
  - `hooks/barnhk/lib/task-completed.sh`

## Capabilities

### New Capabilities

(None - 这是 bug 修复)

### Modified Capabilities

(None - 不影响 spec 级别的行为)

## Impact

- 仅影响 Bark 通知的显示格式
- 不影响通知的发送逻辑和内容
- 纯 bug 修复，无破坏性变更
