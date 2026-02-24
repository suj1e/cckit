## ADDED Requirements

### Requirement: Permission notifications include tool type

The claude-permit notification SHALL include the tool type (Bash, Read, Write, etc.) in the notification body.

#### Scenario: Bash command notification
- **WHEN** a Bash command requires permission
- **THEN** notification includes "[Bash]" prefix

#### Scenario: Read file notification
- **WHEN** a Read tool requires permission
- **THEN** notification includes "[Read]" prefix

### Requirement: Manual approval notifications include context details

Manual approval notifications SHALL include sufficient context for the user to understand what needs approval.

#### Scenario: Bash command with session context
- **WHEN** a non-whitelisted Bash command requires manual approval
- **THEN** notification includes command content, truncated if necessary
- **AND** notification includes session ID

#### Scenario: File operation with path
- **WHEN** a file operation (Read/Write) requires approval
- **THEN** notification includes the file path

### Requirement: Long commands are truncated

Commands longer than 100 characters SHALL be truncated for readability.

#### Scenario: Truncate long command
- **WHEN** command exceeds 100 characters
- **THEN** notification shows first 100 characters with "..." suffix
