# cckit

Claude Code Kit — A collection of Claude Code extensions (skills and hooks).

## Quick Install

```bash
npx @suj1e/cckit
```

This installs all four plugins in one command. No clone, no script.

Or install a specific plugin:

```bash
npx @suj1e/cckit install barnhk
```

## CLI Commands

| Command | Description |
|---------|-------------|
| `npx @suj1e/cckit` | Install all plugins |
| `npx @suj1e/cckit install [name]` | Install all or specific plugin |
| `npx @suj1e/cckit uninstall [name]` | Uninstall all or specific plugin |
| `npx @suj1e/cckit list` | Show installed plugins and status |
| `npx @suj1e/cckit update [name]` | Update plugins |
| `npx @suj1e/cckit info <name>` | Show plugin metadata |

Global install (use `cckit` directly):

```bash
npm install -g @suj1e/cckit
cckit install barnhk
cckit list
```

## Contents

### Skills

| Skill | Description |
|-------|-------------|
| [jbrick](./skills/jbrick) | Spring Boot microservice scaffold generator with 3-module Repository pattern architecture |
| [just-task](./skills/just-task) | Background just command runner for long-running tasks |
| [review-merge-sync](./skills/review-merge-sync) | Code review → merge → sync workflow |

### Hooks

| Hook | Description |
|------|-------------|
| [barnhk](./hooks/barnhk) | Safety and notification hooks with dangerous command protection, auto-approval (docker, file ops), project directory auto-approve toggle, and multi-channel notifications (Bark, Discord, 飞书) |

## Manual Commands

You can also use Claude Code CLI directly:

```bash
# Add marketplace
claude plugin marketplace add /path/to/cckit

# Install
claude plugin install barnhk@cckit --scope user

# Uninstall
claude plugin uninstall barnhk@cckit --scope user
```

## License

MIT
