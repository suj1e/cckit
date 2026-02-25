## Why

barnhk 的 hooks 实现与 Claude Code 官方文档存在不兼容问题：JSON 输入路径错误、退出码使用不规范、输出格式不符合规范。这可能导致 hooks 行为不可预测。同时缺少 SessionEnd hook 来提供会话结束通知。

## What Changes

- 修复 `pre-tool-use.sh` 的 JSON 路径：`.tool` → `.tool_name`，`.input.command` → `.tool_input.command`
- 修复 `permission-request.sh` 的 JSON 路径：`.permission.name` → `.tool_name`，`.permission.command` → `.tool_input.command`，`.permission.path` → `.tool_input.path`
- 修复退出码：阻断命令时使用 `exit 2` 而非 `exit 1`
- 修复 `pre-tool-use.sh` 输出格式：使用 `hookSpecificOutput` 结构化 JSON 输出
- 新增 `session-end.sh` hook：会话结束时发送 Bark 通知
- 新增 `standards/hooks/claude-code-hooks.md`：整理 Claude Code 官方 hooks 规范文档，作为开发参考标准

## Capabilities

### New Capabilities

- `session-end-hook`: 会话结束通知功能，当 Claude Code 会话结束时触发 Bark 推送
- `hooks-spec-doc`: Claude Code hooks 规范文档，包含所有 hook 类型的输入输出格式

### Modified Capabilities

- `hooks-json-parsing`: 修复 hooks 的 JSON 输入解析，使用正确的字段路径
- `hooks-exit-codes`: 规范化 hooks 的退出码使用
- `hooks-output-format`: 规范化 PreToolUse 的 JSON 输出格式

## Impact

- `standards/hooks/claude-code-hooks.md` - 新增规范文档
- `CLAUDE.md` - 添加规范文档引用，强调必须严格遵守
- `hooks/barnhk/lib/pre-tool-use.sh` - 修复 JSON 路径、退出码、输出格式
- `hooks/barnhk/lib/permission-request.sh` - 修复 JSON 路径
- `hooks/barnhk/lib/session-end.sh` - 新增文件
- `hooks/barnhk/lib/common.sh` - 可能需要添加通用函数
- `hooks/barnhk/install.sh` - 注册新的 SessionEnd hook
