## ADDED Requirements

### Requirement: Notify on manual approval needed
The system SHALL send Bark notification when a command requires user approval.

#### Scenario: Send notification for non-whitelisted command
- **WHEN** a command is not in the safe whitelist
- **THEN** the hook SHALL send a Bark notification before waiting for user decision

#### Scenario: Notification includes command details
- **WHEN** sending manual approval notification
- **THEN** the notification body SHALL include the command string
