## ADDED Requirements

### Requirement: Plugin directory structure follows Claude Code specification

All cckit plugins SHALL follow the official Claude Code plugin directory structure as defined in standards/plugins/claude-code-plugins.md.

#### Scenario: panck skill structure
- **WHEN** panck skill is installed
- **THEN** the directory SHALL contain `.claude-plugin/plugin.json` and `SKILL.md` at root level

#### Scenario: barnhk hooks structure
- **WHEN** barnhk hooks plugin is installed
- **THEN** the directory SHALL contain `.claude-plugin/plugin.json` and `hooks/hooks.json`

### Requirement: Plugin uses official claude plugin command

Plugins SHALL be installable using the official `claude plugin install` command.

#### Scenario: Install plugin with official command
- **WHEN** user runs `claude plugin install /path/to/plugin --scope user`
- **THEN** the plugin SHALL be installed to `~/.claude/plugins/` or appropriate location
- **AND** skills SHALL be automatically discovered via SKILL.md
- **AND** hooks SHALL be automatically registered via hooks.json

#### Scenario: Uninstall plugin with official command
- **WHEN** user runs `claude plugin uninstall <plugin-name> --scope user`
- **THEN** the plugin SHALL be removed
- **AND** hooks SHALL be automatically unregistered

### Requirement: cckit provides unified management scripts

cckit SHALL provide install.sh and uninstall.sh at root level for unified plugin management.

#### Scenario: Install all plugins
- **WHEN** user runs `./install.sh` from cckit root
- **THEN** all cckit plugins (panck, barnhk) SHALL be installed

#### Scenario: Install specific plugin
- **WHEN** user runs `./install.sh panck`
- **THEN** only panck plugin SHALL be installed

#### Scenario: Uninstall plugin
- **WHEN** user runs `./uninstall.sh barnhk`
- **THEN** barnhk plugin SHALL be uninstalled
