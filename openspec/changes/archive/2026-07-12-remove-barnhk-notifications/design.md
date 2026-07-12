## Architecture

barnhk 采用纯 bash hook 架构，零网络 I/O，零副作用。所有逻辑在 hook 进程内同步完成，立即返回。

## File Changes

### Deleted

| File | Reason |
|------|--------|
| `lib/notify.sh` | 纯通知入口，已移除 |
| `lib/notification.sh` | 纯 EchoBell webhook 后端，已移除 |
| `lib/transcript.sh` | 纯通知内容提取，无 hook 调用，已移除 |
| `tests/test-notify.sh` | 纯通知测试，已移除 |

### Modified

| File | Change |
|------|--------|
| `lib/common.sh` | 移除 `source notify.sh`、`source transcript.sh`；删除 `get_notification_mode()`、`get_notification_title()`；移除 `dispatch_hook` 的 `notification` case |
| `lib/hooks.sh` | 移除所有 `send_notification` 调用；删除 `hook_notification()` 函数；添加模块级注释说明零副作用原则 |
| `.claude-plugin/plugin.json` | 移除 `Notification` hook 条目；为所有 6 个 hook 添加 `"timeout": 10` |
| `lib/barnhk.env` | 清理为仅 2 行：`SAFE_COMMANDS` 和 `AUTO_APPROVE_PROJECT_COMMANDS` |
| `standards/hooks/claude-code-hooks.md` | 修正 PreToolUse 字段名；增加零副作用和超时最佳实践；Notification 章节增加网络 I/O 警告 |

## Remaining Hook Functions

| Hook | Behavior | Side Effects |
|------|----------|-------------|
| `hook_pre_tool_use` | 检测危险命令，exit 2 阻断 | None |
| `hook_permission_request` | 自动批准安全命令和项目内文件编辑 | None |
| `hook_task_completed` | 空 stub，exit 0 | None |
| `hook_stop` | 空 stub，exit 0 | None |
| `hook_session_end` | 空 stub，exit 0 | None |
| `hook_teammate_idle` | 空 stub，exit 0 | None |

## Configuration

用户配置路径：`~/.claude/cckit/barnhk.env`

```bash
SAFE_COMMANDS=""
AUTO_APPROVE_PROJECT_COMMANDS=true
```

`common.sh` 的 `load_config()` 优先读取用户级配置，找不到则从插件内置模板自动复制。

## Error Handling

- `jq` 解析失败：`2>/dev/null` 静默，字段为空字符串
- 未知 hook name：stderr 输出错误信息，exit 1
- 所有 hook 设置 `timeout: 10`，异常时 Claude Code 自动终止
