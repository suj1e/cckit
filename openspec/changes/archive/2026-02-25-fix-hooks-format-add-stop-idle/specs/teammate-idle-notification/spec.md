## ADDED Requirements

### Requirement: Send notification on teammate idle
The system SHALL send a Bark notification when a teammate goes idle.

#### Scenario: Idle notification sent
- **WHEN** a teammate agent goes idle
- **THEN** the hook SHALL send a Bark notification with teammate info

#### Scenario: Notification includes teammate name
- **WHEN** sending idle notification
- **THEN** the notification body SHALL include the teammate name or ID

### Requirement: TeammateIdle hook script exists
The system SHALL provide a teammate-idle.sh script in the lib directory.

#### Scenario: Script is executable
- **WHEN** install.sh is run
- **THEN** teammate-idle.sh SHALL be executable

#### Scenario: Script sources common functions
- **WHEN** teammate-idle.sh executes
- **THEN** it SHALL source common.sh for shared utilities
