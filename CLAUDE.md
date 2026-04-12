# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a collection of Claude Code extensions - skills and hooks that enhance Claude Code's capabilities.

## Structure

```
cckit/
├── install.sh              # Unified installer
├── uninstall.sh            # Unified uninstaller
├── skills/
│   └── panck/              # Spring Boot microservice scaffold generator
├── hooks/
│   └── barnhk/             # Safety and notification hooks
└── standards/              # 规范文档
    ├── hooks/              # Claude Code hooks 规范
    └── plugins/            # Claude Code plugins 规范
```

## Standards

**IMPORTANT**: 开发 Claude Code 扩展时必须严格遵守以下规范文档：

### Hooks 规范
`standards/hooks/claude-code-hooks.md`

关键规范点：
- JSON 字段名：使用 `tool_name` 和 `tool_input`，不是 `.tool` 或 `.permission`
- 退出码：阻断时使用 `exit 2`，不是 `exit 1`
- 输出格式：使用 `hookSpecificOutput` 结构化 JSON 输出
- **PermissionRequest 格式**：必须使用 `decision.behavior`，而非 PreToolUse 的 `permissionDecision`
  ```json
  {"hookSpecificOutput":{"hookEventName":"PermissionRequest","decision":{"behavior":"allow"}}}
  ```
- **Notification 格式**：输入包含 `message`、`title`、`notification_type` 字段，应显示 `message` 内容而非通用文案

### Plugins 规范
`standards/plugins/claude-code-plugins.md`

覆盖内容：
- Skills、Agents、Hooks、MCP Servers、LSP Servers
- plugin.json manifest schema
- 目录结构规范
- CLI 命令参考

## Skills

### panck - Service Scaffold Generator

Generates production-ready Spring Boot microservice scaffolds with DDD/Clean Architecture patterns.

**Installation:**
```bash
./install.sh panck
```

**Usage in Claude Code:**
```
/panck usersrv
```

**Generated Service Architecture:**
- 4-module Gradle structure: `*-api`, `*-core`, `*-adapter`, `*-boot`
- DDD layered architecture with dependency rule: `boot → adapter → core, api`
- Tech stack: Java 21, Spring Boot 4.0.2, Spring Cloud Alibaba, Nacos, Gradle 9.3.0

**Key templates location:** `skills/panck/assets/templates/`

## Hooks

### barnhk - Safety & Notification Hooks

Provides dangerous command protection, auto-approval for safe commands, and multi-channel notifications.

**Features:**
- Blocks dangerous commands (rm -rf /, sudo, curl | bash)
- Auto-approves safe commands:
  - Git, npm, pnpm, yarn, pip, gradle, mvn, cargo
  - **File operations**: mkdir, touch, cp, mv
  - **Docker**: ps, images, logs, inspect, stats, exec, network ls, volume ls
  - **Docker Compose**: up, down, logs, ps, build, config
- **Project directory auto-approve** - toggle to auto-approve all commands in project dir (default: on)
- **Edit/Write auto-approve** - automatically approves Edit/Write operations for files within project directory
- Multi-channel notifications with project info: Bark (iOS) + Discord + 飞书 Webhook
  - All notifications show project name in title prefix: `[项目名] 标题`
  - **Type-specific titles**: Different notification types use appropriate titles
    - ❓ Claude Question - for `question` type (Claude asks something)
    - ⏳ Claude Waiting - for `idle_prompt` type (Claude waiting for input)
  - **Transcript content extraction**: Question/idle notifications extract specific content from transcript instead of generic messages
  - **Configurable handling**: Each notification type can be set to `skip`, `default`, or `transcript` mode
  - Distinct notification types with color coding:
    - 🔔 Claude Permit (green) - auto-approved commands
    - 🔐 Claude Approval (yellow) - manual approval needed
  - Supports all notification types: danger, permit, approval, done, stop, idle, question
- Cross-platform support (macOS, Linux)

**Installation:**
```bash
./install.sh barnhk
```

**Debug Logging:**

Transcript extraction logs to `/tmp/barnhk-transcript-debug.log` for troubleshooting:
```bash
cat /tmp/barnhk-transcript-debug.log
```

**Configuration:**

After installation, config file is located at:
```
~/.claude/plugins/cache/cckit/barnhk/<version>/lib/barnhk.conf
```

Edit the config:
```bash
# Notifications
BARK_SERVER_URL="https://api.day.app/YOUR_KEY"
DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/..."
FEISHU_WEBHOOK_URL="https://open.feishu.cn/open-apis/bot/v2/hook/..."

# Notification type handling (skip/default/transcript)
# skip = no notification, default = generic message, transcript = extract from transcript
NOTIFICATION_PERMISSION_PROMPT="skip"    # Skip to avoid duplicate with permission-request.sh
NOTIFICATION_QUESTION="transcript"        # Extract specific question content
NOTIFICATION_IDLE_PROMPT="transcript"     # Extract specific waiting content

# Project directory auto-approve (default: true)
# When enabled, all commands in project directory are auto-approved
AUTO_APPROVE_PROJECT_COMMANDS=true

# Debug logging (default: false)
# When enabled, logs hook input/output to /tmp/barnhk-permission-debug.log
DEBUG_ENABLED=false
```

**Feishu Card Layout:**

Approval cards use optimized layout for readability:
```
┌─────────────────────────────────────────┐
│ 🔐 Claude 命令审批请求                    │
├─────────────────────────────────────────┤
│ ⌨️ 命令                                  │
│ `rm -rf build`                          │
├────────────────────┬────────────────────┤
│ 📁 目录             │ 🔗 请求ID           │
│ `/gateway-center`  │ `1234`              │
├────────────────────┴────────────────────┤
│     [✓ 批准]    [✗ 拒绝]                 │
└─────────────────────────────────────────┘
```

Result cards (approved/denied/timeout) also display directory and timestamp.

## Plugin Management

cckit plugins are managed via Claude Code's official marketplace system.

**Hook Loading:** Hooks are defined in `.claude-plugin/plugin.json` and loaded automatically via `enabledPlugins`. No manual registration to `settings.json` is needed.

**Install:**
```bash
./install.sh [plugin-name]
```

**Uninstall:**
```bash
./uninstall.sh [plugin-name]
```

**Manual commands:**
```bash
# Add marketplace
claude plugin marketplace add /path/to/cckit

# Install
claude plugin install barnhk@cckit --scope user

# Uninstall
claude plugin uninstall barnhk@cckit --scope user
```

## Development

When modifying skills or hooks:

1. **Skills** are defined by a `SKILL.md` file with frontmatter specifying `name` and `description`
2. **Hooks** are configured inline in `.claude-plugin/plugin.json` with `${CLAUDE_PLUGIN_ROOT}` for paths
3. **TeammateIdle** input fields are `agent_name` and `agent_id` (not `teammate_*`)
4. **PermissionRequest** uses `decision.behavior` format; **PreToolUse** uses `permissionDecision` format
5. Test changes by reinstalling: `./uninstall.sh <plugin> && ./install.sh <plugin>`

## Known Limitations

### AskUserQuestion Hook Support

The `AskUserQuestion` tool does **not** trigger any hooks in Claude Code:

| Hook Type | Triggered by AskUserQuestion |
|-----------|------------------------------|
| PreToolUse | ❌ No |
| Notification (question type) | ❌ No |
| Notification (idle_prompt type) | ❌ No |

This is a Claude Code limitation. Workaround: Manually check for questions via transcript polling (not implemented).
