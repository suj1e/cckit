## ADDED Requirements

### Requirement: Bark notification body supports multiline format

The system SHALL format Bark notification body content with actual newlines, not literal `\n` characters.

#### Scenario: Multi-line notification displays correctly
- **WHEN** a hook sends a notification with multiple lines of content
- **THEN** the notification body displays each line on a separate line in the Bark app

#### Scenario: Session info displays on separate line
- **WHEN** a permission request notification includes session ID
- **THEN** the session ID displays on a new line below the command text
