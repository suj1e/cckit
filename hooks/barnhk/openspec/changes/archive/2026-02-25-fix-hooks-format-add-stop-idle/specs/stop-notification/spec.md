## ADDED Requirements

### Requirement: Send notification on Claude stop
The system SHALL send a Bark notification when Claude session stops.

#### Scenario: Stop notification sent
- **WHEN** Claude session stops
- **THEN** the hook SHALL send a Bark notification with session info

#### Scenario: Notification includes stop reason
- **WHEN** sending stop notification
- **THEN** the notification body SHALL include the stop reason if available

### Requirement: Stop hook script exists
The system SHALL provide a stop.sh script in the lib directory.

#### Scenario: Script is executable
- **WHEN** install.sh is run
- **THEN** stop.sh SHALL be executable

#### Scenario: Script sources common functions
- **WHEN** stop.sh executes
- **THEN** it SHALL source common.sh for shared utilities
