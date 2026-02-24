## MODIFIED Requirements

### Requirement: Idempotent installation
The install script SHALL support repeated execution without creating duplicate hook configurations.

#### Scenario: Reinstall without duplicates
- **WHEN** install.sh is run multiple times
- **THEN** only one set of barnhk hooks SHALL exist in settings.json

#### Scenario: Clean reinstall after directory move
- **WHEN** barnhk directory is moved to a new location and install.sh is run
- **THEN** old hooks SHALL be removed and new hooks with correct paths SHALL be added

#### Scenario: Correct hook format with string matcher
- **WHEN** install.sh adds hooks to settings.json
- **THEN** PreToolUse and PermissionRequest hooks SHALL use `"Bash"` as matcher string
- **AND** TaskCompleted, Stop, and TeammateIdle hooks SHALL NOT have a matcher field
