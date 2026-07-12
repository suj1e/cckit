## ADDED Requirements

### Requirement: Safety module has test coverage
The safety module (`safety.sh`) SHALL have test coverage for dangerous command detection and safe command whitelisting.

#### Scenario: Critical command detection
- **WHEN** `check_danger_level` is called with `rm -rf /`
- **THEN** it returns `critical`

#### Scenario: Safe command whitelist
- **WHEN** `is_safe_command` is called with `git status`
- **THEN** it returns success (exit 0)

### Requirement: Notify module has dry-run test coverage
The notification module (`notify.sh`) SHALL have test coverage verifying that notification payloads are constructed correctly without actually sending them.

#### Scenario: Notification payload structure
- **WHEN** `send_notification` is called with a group, title, and body
- **THEN** the function constructs correct JSON payloads for each backend

### Requirement: Hook functions have input/output test coverage
Hook functions in `hooks.sh` SHALL have test coverage verifying correct JSON parsing and output format.

#### Scenario: Hook input parsing
- **WHEN** a hook function receives valid JSON on stdin
- **THEN** it correctly extracts named fields and constructs the output
