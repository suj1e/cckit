## ADDED Requirements

### Requirement: Send Bark push notifications (optional)
The system MAY send push notifications to iOS devices via Bark API when configured.

#### Scenario: Send notification with configured server
- **WHEN** a notification event occurs AND BARK_SERVER_URL is configured
- **THEN** the system SHALL send HTTP GET request to configured Bark server URL

#### Scenario: Skip notification when not configured
- **WHEN** BARK_SERVER_URL is not configured or empty
- **THEN** the system SHALL skip notification and continue normally

#### Scenario: Handle notification failure gracefully
- **WHEN** Bark server is unreachable
- **THEN** the system SHALL silently ignore the error and continue execution

### Requirement: Group notifications by type
The system SHALL use different notification groups for different event types.

#### Scenario: Danger notification group
- **WHEN** a dangerous command is blocked
- **THEN** the notification SHALL use group `claude-danger` with alarm sound

#### Scenario: Permission notification group
- **WHEN** a permission request needs user approval
- **THEN** the notification SHALL use group `claude-permit` with bell sound

#### Scenario: Completion notification group
- **WHEN** a task is completed
- **THEN** the notification SHALL use group `claude-done` with glass sound

### Requirement: Configure Bark server URL
The system SHALL allow users to configure their Bark server URL.

#### Scenario: Read server URL from config
- **WHEN** sending a notification
- **THEN** the system SHALL use `BARK_SERVER_URL` from config file

#### Scenario: Validate server URL format
- **WHEN** config is loaded
- **THEN** the system SHALL validate URL starts with `http://` or `https://`

### Requirement: Include relevant details in notifications
The system SHALL include contextual information in notification body.

#### Scenario: Include command in notification
- **WHEN** notifying about command-related event
- **THEN** the notification body SHALL include the command string

#### Scenario: Include timestamp in notification
- **WHEN** sending any notification
- **THEN** the notification SHALL include timestamp of the event

### Requirement: Support notification title customization
The system SHALL allow customization of notification titles per event type.

#### Scenario: Custom title for danger events
- **WHEN** sending danger notification
- **THEN** the title SHALL be configurable via `TITLE_DANGER` config

#### Scenario: Custom title for completion events
- **WHEN** sending completion notification
- **THEN** the title SHALL be configurable via `TITLE_DONE` config
