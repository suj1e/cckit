## ADDED Requirements

### Requirement: Auto-approve git commands
The system SHALL automatically approve common git operations without user confirmation.

#### Scenario: Approve git status
- **WHEN** permission is requested for `git status`
- **THEN** the hook SHALL output approval JSON and exit 0

#### Scenario: Approve git commit
- **WHEN** permission is requested for `git commit` or `git add`
- **THEN** the hook SHALL auto-approve

#### Scenario: Approve git push
- **WHEN** permission is requested for `git push` or `git pull`
- **THEN** the hook SHALL auto-approve

### Requirement: Auto-approve package manager commands
The system SHALL automatically approve common package manager operations.

#### Scenario: Approve npm commands
- **WHEN** permission is requested for `npm install`, `npm run`, or `npm test`
- **THEN** the hook SHALL auto-approve

#### Scenario: Approve pnpm commands
- **WHEN** permission is requested for `pnpm install` or `pnpm run`
- **THEN** the hook SHALL auto-approve

#### Scenario: Approve gradle commands
- **WHEN** permission is requested for `gradle build`, `gradle test`, or `gradle bootRun`
- **THEN** the hook SHALL auto-approve

### Requirement: Auto-approve file read commands
The system SHALL automatically approve read-only file operations.

#### Scenario: Approve ls command
- **WHEN** permission is requested for `ls` or `ls -la`
- **THEN** the hook SHALL auto-approve

#### Scenario: Approve cat command
- **WHEN** permission is requested for `cat` with any file path
- **THEN** the hook SHALL auto-approve

#### Scenario: Approve grep command
- **WHEN** permission is requested for `grep` with any pattern
- **THEN** the hook SHALL auto-approve

### Requirement: Support configurable whitelist
The system SHALL allow users to add custom commands to the auto-approval list.

#### Scenario: Add custom whitelist command
- **WHEN** user adds a command pattern to `SAFE_COMMANDS` in config
- **THEN** matching commands SHALL be auto-approved

### Requirement: Notify on auto-approval
The system SHALL send Bark notification when auto-approving commands.

#### Scenario: Send notification on auto-approval
- **WHEN** a command is auto-approved
- **THEN** the hook SHALL send a Bark notification with command details

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

### Requirement: Notify on manual approval needed
The system SHALL send Bark notification when a command requires user approval.

#### Scenario: Send notification for non-whitelisted command
- **WHEN** a command is not in the safe whitelist
- **THEN** the hook SHALL send a Bark notification before waiting for user decision

#### Scenario: Notification includes command details
- **WHEN** sending manual approval notification
- **THEN** the notification body SHALL include the command string
