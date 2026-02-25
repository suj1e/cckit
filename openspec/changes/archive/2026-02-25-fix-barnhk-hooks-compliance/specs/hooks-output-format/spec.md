## ADDED Requirements

### Requirement: PreToolUse outputs structured JSON

The PreToolUse hook SHALL output structured JSON when blocking operations.

#### Scenario: Output deny decision

- **WHEN** PreToolUse blocks a dangerous command
- **THEN** it outputs JSON with `hookSpecificOutput.permissionDecision` set to "deny"
- **AND** includes `denyReason` field with explanation

#### Scenario: JSON output format

- **WHEN** outputting block decision
- **THEN** JSON format is: `{"hookSpecificOutput":{"permissionDecision":"deny","denyReason":"<reason>"}}`

### Requirement: PreToolUse outputs to stdout

The PreToolUse hook SHALL output decision JSON to stdout, not stderr.

#### Scenario: stdout for decision

- **WHEN** blocking a command
- **THEN** JSON output goes to stdout
- **AND** error messages for logging go to stderr
