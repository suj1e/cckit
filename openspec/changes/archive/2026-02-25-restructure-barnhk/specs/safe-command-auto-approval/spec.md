## ADDED Requirements

### Requirement: Idempotent installation
The install script SHALL support repeated execution without creating duplicate hook configurations.

#### Scenario: Reinstall without duplicates
- **WHEN** install.sh is run multiple times
- **THEN** only one set of barnhk hooks SHALL exist in settings.json

#### Scenario: Clean reinstall after directory move
- **WHEN** barnhk directory is moved to a new location and install.sh is run
- **THEN** old hooks SHALL be removed and new hooks with correct paths SHALL be added

### Requirement: Clean uninstallation
The uninstall script SHALL remove all barnhk-related hooks from settings.

#### Scenario: Remove all barnhk hooks
- **WHEN** uninstall.sh is run
- **THEN** all hooks with paths containing "barnhk" SHALL be removed from settings.json

#### Scenario: Preserve other hooks
- **WHEN** uninstall.sh is run
- **THEN** non-barnhk hooks SHALL remain unchanged in settings.json
