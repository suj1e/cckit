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
