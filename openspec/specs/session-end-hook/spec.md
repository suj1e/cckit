## ADDED Requirements

### Requirement: SessionEnd hook triggers on session end

The system SHALL invoke the SessionEnd hook when a Claude Code session ends completely.

#### Scenario: Session ends with notification

- **WHEN** Claude Code session ends
- **THEN** session-end.sh hook is invoked
- **AND** Bark notification is sent to claude-stop group

### Requirement: SessionEnd hook receives session context

The SessionEnd hook SHALL receive session context via stdin JSON input.

#### Scenario: JSON input parsing

- **WHEN** session-end.sh is invoked
- **THEN** it parses JSON input containing session_id
- **AND** extracts session information for notification

### Requirement: SessionEnd notification format

The SessionEnd notification SHALL include session identifier for tracking.

#### Scenario: Notification body format

- **WHEN** sending Bark notification
- **THEN** notification body includes "[SESSION] Session ended"
- **AND** includes truncated session ID (last 8 characters)
