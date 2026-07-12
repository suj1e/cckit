## Why

通知功能在 hook 内做网络 I/O（curl EchoBell），导致 Claude Code 拉起大量并行子进程（进程名匹配通知标题），造成资源浪费和潜在费用。官方最佳实践（[Claude Code Hooks 文档](https://code.claude.com/docs/en/hooks)）明确指出 hook 应零副作用：不做网络 I/O、不产生长期运行的后台进程。

## What Changes

彻底移除 barnhk 的通知功能，保留纯安全防护能力：

- **BREAKING**: 删除 `lib/notify.sh`、`lib/notification.sh`、`lib/transcript.sh`
- **BREAKING**: 删除 `tests/test-notify.sh`
- 从 `lib/common.sh` 移除通知相关函数（`get_notification_mode`、`get_notification_title`）和 `source` 调用
- 从 `lib/hooks.sh` 移除所有 `send_notification` 调用和 `hook_notification()` 函数
- 从 `plugin.json` 移除 `Notification` hook 条目
- 为所有剩余 hook 添加 `"timeout": 10`（官方最佳实践）
- 清理 `lib/barnhk.env`（去掉 `ECHOBELL_TOKEN`、所有 `TITLE_*`、`NOTIFICATION_*`、`DEBUG_ENABLED`）
- 更新规范文档 `standards/hooks/claude-code-hooks.md`：修正 PreToolUse 输出字段名（`denyReason` → `permissionDecisionReason`）、增加"零副作用"和"设置超时"最佳实践、Notification 章节增加网络 I/O 警告

## Capabilities

### Modified Capabilities

- **barnhk-hooks**: 移除通知功能，hook 仅做安全判断和自动批准，零副作用

## Impact

- 用户不再收到 EchoBell 推送通知
- hook 执行时间从数百毫秒（含 curl）降至数毫秒（纯 bash + jq）
- 消除并行子进程泄漏问题
- 配置路径 `~/.claude/cckit/barnhk.env` 保留，仅保留 `SAFE_COMMANDS` 和 `AUTO_APPROVE_PROJECT_COMMANDS`
