## ADDED Requirements

### Requirement: PreToolUse uses correct JSON paths

The PreToolUse hook SHALL parse JSON input using official Claude Code field names.

#### Scenario: Parse tool_name field

- **WHEN** pre-tool-use.sh receives JSON input
- **THEN** it extracts tool name from `.tool_name` field
- **AND** NOT from `.tool` field

#### Scenario: Parse tool_input.command field

- **WHEN** pre-tool-use.sh receives JSON input for Bash tool
- **THEN** it extracts command from `.tool_input.command` field
- **AND** NOT from `.input.command` field

### Requirement: PermissionRequest uses correct JSON paths

The PermissionRequest hook SHALL parse JSON input using official Claude Code field names.

#### Scenario: Parse tool_name field

- **WHEN** permission-request.sh receives JSON input
- **THEN** it extracts tool name from `.tool_name` field
- **AND** NOT from `.permission.name` field

#### Scenario: Parse tool_input fields

- **WHEN** permission-request.sh receives JSON input
- **THEN** it extracts command from `.tool_input.command` field
- **AND** it extracts path from `.tool_input.path` field
- **AND** NOT from `.permission.command` or `.permission.path`
