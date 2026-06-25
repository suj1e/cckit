# cckit

Claude Code Kit - A collection of Claude Code extensions (skills and hooks).

## Contents

### Skills

| Skill | Description |
|-------|-------------|
| [jbrick](./skills/jbrick) | Spring Boot microservice scaffold generator with 3-module Repository pattern architecture |

### Hooks

| Hook | Description |
|------|-------------|
| [barnhk](./hooks/barnhk) | Safety and notification hooks with dangerous command protection, auto-approval (docker, file ops), project directory auto-approve toggle, and multi-channel notifications |

## Installation

cckit uses Claude Code's official marketplace system. Use the unified installer:

### Unix (macOS / Linux)

```bash
# Install all plugins
./install.sh

# Install specific plugin
./install.sh jbrick
./install.sh barnhk
```

### Windows

Double-click `install.bat` or run in PowerShell:

```powershell
# Install all plugins
.\install.ps1

# Install specific plugin
.\install.ps1 barnhk
```

The installer will:
1. Add cckit as a local marketplace
2. Install plugins via `claude plugin install`
3. Hooks are automatically loaded via `plugin.json` through `enabledPlugins`

## Uninstallation

### Unix (macOS / Linux)

```bash
# Uninstall all plugins
./uninstall.sh

# Uninstall specific plugin
./uninstall.sh barnhk
```

### Windows

```powershell
.\uninstall.ps1
.\uninstall.ps1 barnhk
```

## Manual Commands

You can also use Claude Code CLI directly:

```bash
# Add marketplace
claude plugin marketplace add /path/to/cckit

# Install
claude plugin install barnhk@cckit --scope user
claude plugin install jbrick@cckit --scope user

# Uninstall
claude plugin uninstall barnhk@cckit --scope user
```

## License

MIT
