## ADDED Requirements

### Requirement: Global installation directory
The install script SHALL copy hook files to a global directory under `~/.claude/hooks/barnhk/`.

#### Scenario: Copy files to global directory
- **WHEN** install.sh is run
- **THEN** all files in `lib/` SHALL be copied to `~/.claude/hooks/barnhk/lib/`

#### Scenario: Preserve existing config
- **WHEN** install.sh is run and `~/.claude/hooks/barnhk/lib/barnhk.conf` already exists
- **THEN** the existing config SHALL NOT be overwritten

### Requirement: Global path in settings
The install script SHALL reference global paths in settings.json.

#### Scenario: Use global paths
- **WHEN** install.sh adds hooks to settings.json
- **THEN** all paths SHALL point to `~/.claude/hooks/barnhk/lib/`

### Requirement: Clean uninstall
The uninstall script SHALL remove the global installation directory.

#### Scenario: Remove global directory
- **WHEN** uninstall.sh is run
- **THEN** `~/.claude/hooks/barnhk/` directory SHALL be removed
