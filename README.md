# cckit

Claude Code Kit - A collection of Claude Code extensions (skills and hooks).

## Contents

### Skills

| Skill | Description |
|-------|-------------|
| [panck](./skills/panck) | Spring Boot microservice scaffold generator with DDD/Clean Architecture patterns |

### Hooks

| Hook | Description |
|------|-------------|
| [barnhk](./hooks/barnhk) | Safety and notification hooks with dangerous command protection, auto-approval (git/npm/gradle/openspec), remote approval via cplit, and color-coded multi-channel notifications (Bark/Discord/飞书) |

## Installation

cckit uses Claude Code's official marketplace system. Use the unified installer:

```bash
# Install all plugins
./install.sh

# Install specific plugin
./install.sh panck
./install.sh barnhk
```

The installer will:
1. Add cckit as a local marketplace
2. Install plugins via `claude plugin install`
3. Automatically register hooks to `settings.json`

## Uninstallation

```bash
# Uninstall all plugins
./uninstall.sh

# Uninstall specific plugin
./uninstall.sh barnhk
```

## Manual Commands

You can also use Claude Code CLI directly:

```bash
# Add marketplace
claude plugin marketplace add /path/to/cckit

# Install
claude plugin install barnhk@cckit --scope user
claude plugin install panck@cckit --scope user

# Uninstall
claude plugin uninstall barnhk@cckit --scope user
```

## License

MIT
