## ADDED Requirements

### Requirement: Auto-approval JSON output is clean

The permission-request hook SHALL output ONLY the JSON decision to stdout, with no other content before or after.

#### Scenario: Safe command auto-approval
- **WHEN** a safe command (e.g., `git status`) is detected
- **THEN** the hook outputs exactly `{"hookSpecificOutput":{"permissionDecision":"allow"}}` to stdout and nothing else

#### Scenario: JSON output comes before any other operations
- **WHEN** the hook decides to auto-approve
- **THEN** the JSON is output to stdout before any notifications are sent
