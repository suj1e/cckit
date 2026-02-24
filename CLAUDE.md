# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a collection of Claude Code extensions - skills and hooks that enhance Claude Code's capabilities.

## Structure

```
cckit/
├── skills/           # Claude Code skills
│   └── panck/        # Spring Boot microservice scaffold generator
└── hooks/            # Claude Code hooks
    └── barnhk/       # Safety and notification hooks
```

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

Provides dangerous command protection, auto-approval for safe commands, and Bark push notifications.

**Features:**
- Blocks dangerous commands (rm -rf /, sudo, curl | bash)
- Auto-approves safe commands (git, npm, gradle)
- Sends Bark notifications for permission requests and task completion

**Installation:**
```bash
cd hooks/barnhk && ./install.sh
```

## Development

When modifying skills or hooks:

1. **Skills** are defined by a `SKILL.md` file with frontmatter specifying `name` and `description`
2. **Hooks** are shell scripts configured via Claude Code's settings
3. Test changes by re-running the respective `install.sh` script
