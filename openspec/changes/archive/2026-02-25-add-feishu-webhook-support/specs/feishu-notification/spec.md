## ADDED Requirements

### Requirement: Feishu webhook notification function exists

The system SHALL provide a `send_feishu_notification()` function that sends notifications to Feishu via webhook.

#### Scenario: Send notification to Feishu
- **WHEN** `send_feishu_notification` is called with group, title, and body
- **THEN** a POST request is sent to the configured Feishu webhook URL

#### Scenario: Skip if not configured
- **WHEN** `FEISHU_WEBHOOK_URL` is not set or empty
- **THEN** the function returns immediately without sending

### Requirement: Feishu notifications use card format

The system SHALL format Feishu notifications using interactive card structure with appropriate colors.

#### Scenario: Danger notification has red color
- **WHEN** a notification with group `claude-danger` is sent
- **THEN** the Feishu card has red header template

#### Scenario: Permit notification has green color
- **WHEN** a notification with group `claude-permit` is sent
- **THEN** the Feishu card has green header template

### Requirement: Configuration supports Feishu settings

The configuration file SHALL support Feishu webhook URL.

#### Scenario: Configure Feishu webhook
- **WHEN** user sets `FEISHU_WEBHOOK_URL` in barnhk.conf
- **THEN** notifications are sent to that Feishu group
