## ADDED Requirements

### Requirement: Type-specific notification titles

Notification hook SHALL use different titles based on `notification_type` to help users quickly identify the nature of the notification.

#### Scenario: Question type uses question title
- **WHEN** notification type is `question`
- **THEN** the notification title SHALL be `TITLE_QUESTION` (default: "❓ Claude Question")

#### Scenario: Idle prompt type uses waiting title
- **WHEN** notification type is `idle_prompt`
- **THEN** the notification title SHALL be `TITLE_IDLE_PROMPT` (default: "⏳ Claude Waiting")

#### Scenario: Unknown type uses default title
- **WHEN** notification type is not recognized
- **THEN** the notification title SHALL fall back to `TITLE_QUESTION`

### Requirement: Title configuration variables

System SHALL provide configurable title variables for each notification type.

#### Scenario: Title idle prompt configuration
- **WHEN** `TITLE_IDLE_PROMPT` is configured in barnhk.conf
- **THEN** that value SHALL be used for idle_prompt notifications

#### Scenario: Title idle prompt default
- **WHEN** `TITLE_IDLE_PROMPT` is not configured
- **THEN** the default value SHALL be "⏳ Claude Waiting"
