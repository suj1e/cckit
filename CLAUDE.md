# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

cckit is a collection of Claude Code extensions — skills and hooks — distributed as the npm package `@suj1e/cckit`.

## Structure

```
cckit/
├── package.json               # npm package metadata
├── bin/cli.js                 # CLI: install/uninstall/list/update/info
├── .claude-plugin/
│   └── marketplace.json       # Marketplace definition (3 plugins)
├── skills/
│   └── review-merge-sync/     # Code review → merge → sync
│   ├── ship/                  # End-to-end dev workflow
├── hooks/
│   └── barnhk/                # Safety hooks
├── standards/                 # Hooks & plugins 规范文档
└── .github/workflows/         # CI/CD (npm publish on tag)
```

## Plugin Management

### For Users (npm)

```bash
npx @suj1e/cckit                    # install all plugins
npx @suj1e/cckit install <name>     # install specific
npx @suj1e/cckit uninstall <name>   # uninstall
cckit list                          # show installed plugins
cckit info <name>                   # plugin details
cckit update                        # update plugins
```

### For Development (test unreleased changes)

```bash
node bin/cli.js install --local    # install from local repo (directory source)
node bin/cli.js uninstall <name>   # uninstall
node bin/cli.js list               # list
```

### Manual (claude CLI)

```bash
claude plugin marketplace add /path/to/cckit
claude plugin install barnhk@cckit --scope user
claude plugin uninstall barnhk@cckit --scope user
```

## Release

发版全自动，零手工：

1. 打开 [Actions](https://github.com/suj1e/cckit/actions) → Publish to npm → Run workflow
2. 选择 `patch` / `minor` / `major`
3. CI 自动完成：
   - 从 git log 生成/更新 `CHANGELOG.md`
   - bump `package.json` 版本
   - commit + 打 tag + push
   - tag 触发 → `npm publish` → 自动创建 GitHub Release

提交时用 conventional commits (`feat:`, `fix:`, `chore:`)，changelog 按类型自动分组。

CI workflow: `.github/workflows/publish.yml`

## Standards

开发时必须遵守以下规范：

### Hooks 规范 (`standards/hooks/claude-code-hooks.md`)

- JSON 字段名：`tool_name`、`tool_input`（不是 `.tool` 或 `.permission`）
- 退出码：阻断用 `exit 2`，不是 `exit 1`
- 输出：`hookSpecificOutput` 结构化 JSON
- **PreToolUse 输出**: `permissionDecision` + `denyReason`
- **PermissionRequest 输出**: `decision.behavior`（不是 `permissionDecision`）
  ```json
  {"hookSpecificOutput":{"hookEventName":"PermissionRequest","decision":{"behavior":"allow"}}}
  ```
- **Notification 输入**: `message`、`title`、`notification_type` — 显示 `message` 内容而非通用文案

### Plugins 规范 (`standards/plugins/claude-code-plugins.md`)

覆盖 Skills、Agents、Hooks、MCP/LSP Servers、plugin.json schema、目录结构、CLI 命令。

## Skills

### review-merge-sync

代码审查 → 合并 → 推送 → 同步 worktree 工作流。

- 用法: `/review-merge-sync <branch> [target]`

### ship

端到端开发工作流：OpenSpec brainstorming → design → plan → implement → verify → archive。

- 用法: `/ship <change-name>`
- 依赖 OpenSpec CLI (`openspec` 命令) 和 `superpowers` skills

## Hooks

### barnhk

安全防护插件，钩住 6 个事件。纯 bash，每个 hook 入口独立脚本。

```bash
# 运行测试
bash hooks/barnhk/tests/test-safety.sh
```

**功能**：
- 拦截危险命令（rm -rf /, sudo, curl | bash, dd, mkfs, chmod 777 /）
- 自动批准安全命令（git, npm, pnpm, yarn, pip, gradle, mvn, cargo, docker, docker compose, mkdir, touch, cp, mv, ls, cat, grep, find, openspec）
- 项目目录自动批准（`AUTO_APPROVE_PROJECT_COMMANDS=true`）
- Edit/Write 文件操作自动批准
- 纯 bash，跨平台（Windows 通过 Git Bash）

**配置路径**（安装后）: `~/.claude/cckit/barnhk.env`（用户配置优先），回退 `lib/barnhk.conf`（默认配置）

## Development

1. **Skills**: `SKILL.md` + frontmatter (`name`, `description`)
2. **Hooks**: `.claude-plugin/plugin.json` 内联定义，`${CLAUDE_PLUGIN_ROOT}` 引用路径
3. **TeammateIdle** 输入字段: `agent_name` / `agent_id`（不是 `teammate_*`）
4. **PermissionRequest** → `decision.behavior`；**PreToolUse** → `permissionDecision`
5. 测试: `node bin/cli.js install barnhk && node bin/cli.js uninstall barnhk && node bin/cli.js install ship && node bin/cli.js uninstall ship`
6. **barnhk 结构**: `common.sh`（共享函数：安全检测 + 工具函数），每个 hook 事件独立脚本（pre-tool-use.sh, permission-request.sh, notification.sh, stop.sh, session-end.sh, task-completed.sh, teammate-idle.sh）

## Known Limitations

`AskUserQuestion` 不触发任何 hook（PreToolUse、Notification 均不触发）。这是 Claude Code 的限制，无 workaround。
