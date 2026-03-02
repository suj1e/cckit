# Question Notification Content (Delta)

Modified requirements for question notification content to support transcript extraction and type-based configuration.

## MODIFIED Requirements

### Requirement: Notification displays message content

Notification hook SHALL display content based on the configured mode for each notification type.

#### Scenario: Permission prompt with skip mode
- **WHEN** Claude sends a notification with `notification_type: "permission_prompt"` and mode is `skip`
- **THEN** no notification SHALL be sent

#### Scenario: Question with transcript mode
- **WHEN** Claude sends a notification with `notification_type: "question"` and mode is `transcript`
- **THEN** the notification body SHALL contain content extracted from transcript (if available) or fall back to `message` field

#### Scenario: Unknown type with default mode
- **WHEN** Claude sends a notification with unknown `notification_type` and mode is `default`
- **THEN** the notification body SHALL contain the `message` field content

### Requirement: Notification type icon prefix

Notification hook SHALL prepend an icon based on `notification_type` (unchanged, carried forward).

#### Scenario: Permission prompt uses lock icon
- **WHEN** notification type is `permission_prompt` and mode is not `skip`
- **THEN** the notification body SHALL start with "🔐"

#### Scenario: Question uses question mark icon
- **WHEN** notification type is `question`
- **THEN** the notification body SHALL start with "❓"

#### Scenario: Unknown type uses bell icon
- **WHEN** notification type is not recognized
- **THEN** the notification body SHALL start with "🔔"
