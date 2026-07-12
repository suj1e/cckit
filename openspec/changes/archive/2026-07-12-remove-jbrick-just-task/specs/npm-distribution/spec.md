## MODIFIED Requirements

### Requirement: One-command installation via npx
Users SHALL be able to install all cckit plugins with a single `npx` command, without cloning the repository.

#### Scenario: Install all plugins with npx
- **WHEN** a user runs `npx @suj1e/cckit`
- **THEN** the CLI MUST register the package directory as a Claude Code marketplace
- **AND** install the two plugins (barnhk, review-merge-sync) via `claude plugin install`

### Requirement: CLI uninstall subcommand
The CLI SHALL support `uninstall [name]` to uninstall all cckit plugins or a specific named plugin.

#### Scenario: Uninstall all plugins
- **WHEN** a user runs `cckit uninstall` without a name
- **THEN** both cckit plugins MUST be uninstalled
