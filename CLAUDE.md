# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a collection of Claude Code extensions - skills and hooks that enhance Claude Code's capabilities.

## Structure

```
cckit/
├── skills/           # Claude Code skills
│   └── panck/        # Spring Boot microservice scaffold generator
├── hooks/            # Claude Code hooks
│   └── barnhk/       # Safety and notification hooks
└── standards/        # 规范文档
    ├── hooks/        # Claude Code hooks 规范
    └── plugins/      # Claude Code plugins 规范 (skills, agents, MCP, LSP)
```

## Standards

**IMPORTANT**: 开发 Claude Code 扩展时必须严格遵守以下规范文档：

### Hooks 规范
`standards/hooks/claude-code-hooks.md`

关键规范点：
- JSON 字段名：使用 `tool_name` 和 `tool_input`，不是 `.tool` 或 `.permission`
- 退出码：阻断时使用 `exit 2`，不是 `exit 1`
- 输出格式：使用 `hookSpecificOutput` 结构化 JSON 输出

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
cd skills/panck && ./install.sh
```

**Usage in Claude Code:**
```
/panck usersrv
```

**Generated Service Architecture:**
- 4-module Gradle structure: `*-api`, `*-core`, `*-adapter`, `*-boot`
- DDD layered architecture with dependency rule: `boot → adapter → core, api`
- Tech stack: Java 21, Spring Boot 4.0.2, Spring Cloud Alibaba, Nacos, Gradle 9.3.0

**Key templates location:** `skills/panck/panck-plugin/assets/templates/`

## Hooks

### barnhk - Safety & Notification Hooks

Provides dangerous command protection, auto-approval for safe commands, and multi-channel notifications.

**Features:**
- Blocks dangerous commands (rm -rf /, sudo, curl | bash)
- Auto-approves safe commands (git, npm, gradle)
- Multi-channel notifications: Bark (iOS) + Discord + 飞书 Webhook
- Cross-platform support (macOS, Linux)

**Installation:**
```bash
cd hooks/barnhk && ./install.sh
```

**Configuration:**
Edit `~/.claude/hooks/barnhk/lib/barnhk.conf`:
```bash
BARK_SERVER_URL="https://api.day.app/YOUR_KEY"
DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/..."
FEISHU_WEBHOOK_URL="https://open.feishu.cn/open-apis/bot/v2/hook/..."
```

**Debug mode:**
```bash
VERBOSE=true ./install.sh
```

## Development

When modifying skills or hooks:

1. **Skills** are defined by a `SKILL.md` file with frontmatter specifying `name` and `description`
2. **Hooks** are shell scripts configured via Claude Code's settings
3. Test changes by re-running the respective `install.sh` script
