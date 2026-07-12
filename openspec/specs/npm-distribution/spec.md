# npm-distribution

## Purpose

将 cckit 作为 `@suj1e/cckit` npm 包分发，提供 `npx` 一键安装体验，替代旧的 clone + shell 脚本安装方式。

## Requirements

### Requirement: npm package distribution
cckit SHALL be published as the npm package `@suj1e/cckit`, containing all plugin source files (skills/, hooks/, standards/, .claude-plugin/) and a Node.js CLI entry point at `bin/cli.js`.

#### Scenario: Package structure
- **WHEN** a user runs `npm pack @suj1e/cckit` or installs the package
- **THEN** the package MUST contain `bin/cli.js`, `.claude-plugin/marketplace.json`, `skills/`, `hooks/`, and `standards/` directories
- **AND** the package MUST NOT contain `install.sh`, `install.ps1`, `install.bat`, `uninstall.sh`, `uninstall.ps1`

### Requirement: One-command installation via npx
Users SHALL be able to install all cckit plugins with a single `npx` command, without cloning the repository.

#### Scenario: Install all plugins with npx
- **WHEN** a user runs `npx @suj1e/cckit`
- **THEN** the CLI MUST register the package directory as a Claude Code marketplace
- **AND** install all four plugins (jbrick, barnhk, just-task, review-merge-sync) via `claude plugin install`
- **AND** display installation results (success/failure per plugin)

### Requirement: Global install and cckit command
Users SHALL be able to install the package globally and use the `cckit` command directly.

#### Scenario: Global install usage
- **WHEN** a user runs `npm install -g @suj1e/cckit`
- **THEN** `cckit` MUST be available as a system command
- **AND** `cckit install` MUST work identically to `npx @suj1e/cckit install`

### Requirement: CLI install subcommand
The CLI SHALL support `install [name]` to install all plugins or a specific named plugin.

#### Scenario: Install specific plugin
- **WHEN** a user runs `cckit install barnhk`
- **THEN** only the barnhk plugin MUST be installed
- **AND** other plugins MUST NOT be affected

#### Scenario: Install with marketplace already registered
- **WHEN** the cckit marketplace is already registered in known_marketplaces.json
- **THEN** the CLI MUST skip the `marketplace add` step and proceed to install

### Requirement: CLI uninstall subcommand
The CLI SHALL support `uninstall [name]` to uninstall all cckit plugins or a specific named plugin.

#### Scenario: Uninstall specific plugin
- **WHEN** a user runs `cckit uninstall just-task`
- **THEN** the just-task plugin MUST be uninstalled via `claude plugin uninstall just-task@cckit`
- **AND** other plugins MUST remain installed

#### Scenario: Uninstall all plugins
- **WHEN** a user runs `cckit uninstall` without a name
- **THEN** all four cckit plugins MUST be uninstalled

### Requirement: CLI list subcommand
The CLI SHALL support `list` to display installed cckit plugins and their status.

#### Scenario: List installed plugins
- **WHEN** a user runs `cckit list`
- **THEN** the CLI MUST display each cckit plugin name, version, and installation status

### Requirement: CLI update subcommand
The CLI SHALL support `update [name]` to update plugins via `claude plugin update`.

#### Scenario: Update all plugins
- **WHEN** a user runs `cckit update`
- **THEN** the CLI MUST call `claude plugin update <name>@cckit` for each installed plugin

### Requirement: CLI info subcommand
The CLI SHALL support `info <name>` to display metadata about a specific plugin.

#### Scenario: Show plugin info
- **WHEN** a user runs `cckit info barnhk`
- **THEN** the CLI MUST display the plugin's description, version, author, and available hook events
