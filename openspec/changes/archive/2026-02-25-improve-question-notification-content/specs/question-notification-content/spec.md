## ADDED Requirements

### Requirement: Notification displays message content

Notification hook SHALL display the `message` field content from the input JSON for all notification types.

#### Scenario: Permission prompt shows specific tool
- **WHEN** Claude sends a notification with `notification_type: "permission_prompt"` and `message: "Claude needs your permission to use Bash"`
- **THEN** the notification body SHALL contain "Claude needs your permission to use Bash"

#### Scenario: Question notification shows content
- **WHEN** Claude sends a notification with `notification_type: "question"` and `message: "Which file do you want to edit?"`
- **THEN** the notification body SHALL contain "Which file do you want to edit?"

#### Scenario: Unknown type shows message with default icon
- **WHEN** Claude sends a notification with unknown `notification_type` and `message: "Something happened"`
- **THEN** the notification body SHALL contain "Something happened"

### Requirement: Notification type icon prefix

Notification hook SHALL prepend an icon based on `notification_type` to help users quickly identify the notification category.

#### Scenario: Permission prompt uses lock icon
- **WHEN** notification type is `permission_prompt`
- **THEN** the notification body SHALL start with "🔐"

#### Scenario: Question uses question mark icon
- **WHEN** notification type is `question`
- **THEN** the notification body SHALL start with "❓"

#### Scenario: Unknown type uses bell icon
- **WHEN** notification type is not recognized
- **THEN** the notification body SHALL start with "🔔"

### Requirement: Message length truncation

Notification hook SHALL truncate messages longer than 200 characters to keep notifications concise.

#### Scenario: Short message unchanged
- **WHEN** message is "Claude needs your permission to use Bash" (41 characters)
- **THEN** the full message SHALL be displayed without truncation

#### Scenario: Long message truncated
- **WHEN** message exceeds 200 characters
- **THEN** only the first 200 characters SHALL be displayed with "..." appended

### Requirement: Session ID appended to notification

Notification hook SHALL append the session ID to the notification body when available.

#### Scenario: Session ID included
- **WHEN** input contains `session_id: "abc123"`
- **THEN** the notification body SHALL include "Session: abc123"
