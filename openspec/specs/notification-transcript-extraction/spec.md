# Notification Transcript Extraction

Extract specific content from transcript file for notification messages.

## ADDED Requirements

### Requirement: Transcript content extraction

Notification hook SHALL extract the last assistant text message from transcript file when configured with `transcript` mode.

#### Scenario: Extract last assistant text
- **WHEN** notification type is configured as `transcript` mode and transcript file contains assistant message with text content
- **THEN** the notification body SHALL contain the extracted text content instead of generic message

#### Scenario: Session ID validation
- **WHEN** extracting content from transcript
- **THEN** the system SHALL verify the transcript entry's `sessionId` matches the current session's `session_id` before using the content

#### Scenario: Fallback to generic message
- **WHEN** transcript extraction fails (file not found, no matching session, no text content)
- **THEN** the notification body SHALL fall back to the generic `message` field

### Requirement: Notification type configuration

Notification hook SHALL support configurable handling modes for each notification type.

#### Scenario: Skip mode
- **WHEN** notification type is configured with `skip` mode
- **THEN** no notification SHALL be sent for that type

#### Scenario: Default mode
- **WHEN** notification type is configured with `default` mode
- **THEN** the notification SHALL use the generic `message` field

#### Scenario: Transcript mode
- **WHEN** notification type is configured with `transcript` mode
- **THEN** the notification SHALL attempt to extract specific content from transcript

### Requirement: Content truncation

Extracted transcript content SHALL be truncated to 200 characters to keep notifications concise.

#### Scenario: Long content truncated
- **WHEN** extracted text exceeds 200 characters
- **THEN** only the first 200 characters SHALL be displayed with "..." appended

### Requirement: Default configuration values

The following default configuration values SHALL be applied:

#### Scenario: Permission prompt default
- **WHEN** `NOTIFICATION_PERMISSION_PROMPT` is not configured
- **THEN** the default value SHALL be `skip`

#### Scenario: Question default
- **WHEN** `NOTIFICATION_QUESTION` is not configured
- **THEN** the default value SHALL be `transcript`

#### Scenario: Idle prompt default
- **WHEN** `NOTIFICATION_IDLE_PROMPT` is not configured
- **THEN** the default value SHALL be `transcript`
