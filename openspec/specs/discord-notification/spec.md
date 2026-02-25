## ADDED Requirements

### Requirement: Discord webhook notification function exists

The system SHALL provide a `send_discord_notification()` function that sends notifications to Discord via webhook.

#### Scenario: Send notification to Discord
- **WHEN** `send_discord_notification` is called with group, title, and body
- **THEN** a POST request is sent to the configured Discord webhook URL

#### Scenario: Skip if not configured
- **WHEN** `DISCORD_WEBHOOK_URL` is not set or empty
- **THEN** the function returns immediately without sending

### Requirement: Unified notification entry point exists

The system SHALL provide a `send_notification()` function that sends notifications to all configured backends.

#### Scenario: Send to both Bark and Discord
- **WHEN** both `BARK_SERVER_URL` and `DISCORD_WEBHOOK_URL` are configured
- **THEN** notifications are sent to both Bark and Discord

#### Scenario: Send only to configured backends
- **WHEN** only one backend URL is configured
- **THEN** notification is sent only to that backend

### Requirement: Discord notifications use Embed format

The system SHALL format Discord notifications using Embed structure with appropriate colors.

#### Scenario: Danger notification has red color
- **WHEN** a notification with group `claude-danger` is sent
- **THEN** the Discord embed has red color (15548997)

#### Scenario: Permit notification has green color
- **WHEN** a notification with group `claude-permit` is sent
- **THEN** the Discord embed has green color (5763719)

#### Scenario: Done notification has blue color
- **WHEN** a notification with group `claude-done` is sent
- **THEN** the Discord embed has blue color (3066993)

### Requirement: Configuration supports Discord settings

The configuration file SHALL support Discord webhook URL and color settings.

#### Scenario: Configure Discord webhook
- **WHEN** user sets `DISCORD_WEBHOOK_URL` in barnhk.conf
- **THEN** notifications are sent to that Discord channel
