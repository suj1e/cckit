## ADDED Requirements

### Requirement: Cplit integration is configurable and disabled by default

The system SHALL provide configuration options to enable/disable cplit integration, with the default state being disabled.

#### Scenario: Default configuration
- **WHEN** no cplit configuration is provided
- **THEN** cplit integration SHALL be disabled
- **AND** non-whitelisted commands SHALL fall back to local manual approval

#### Scenario: Explicit enable
- **WHEN** `CPLIT_ENABLED=true` and `CPLIT_URL` is set
- **THEN** cplit integration SHALL be enabled for non-whitelisted commands

#### Scenario: Enabled but no URL
- **WHEN** `CPLIT_ENABLED=true` but `CPLIT_URL` is empty or not set
- **THEN** cplit integration SHALL be treated as disabled
- **AND** a warning MAY be logged

### Requirement: Non-whitelisted commands request remote approval via cplit

When cplit is enabled and a command is not in the whitelist, the system SHALL call the cplit `/request-approval` endpoint and wait for a response.

#### Scenario: Remote approval granted
- **WHEN** a non-whitelisted command is encountered
- **AND** cplit is enabled
- **AND** cplit returns `{"decision": "approve"}`
- **THEN** the system SHALL output `{"hookSpecificOutput":{"hookEventName":"PermissionRequest","decision":{"behavior":"allow"}}}`
- **AND** the command SHALL be allowed to execute

#### Scenario: Remote approval denied
- **WHEN** a non-whitelisted command is encountered
- **AND** cplit is enabled
- **AND** cplit returns `{"decision": "deny"}`
- **THEN** the system SHALL output `{"hookSpecificOutput":{"hookEventName":"PermissionRequest","decision":{"behavior":"deny"}}}`
- **AND** the command SHALL be blocked

#### Scenario: cplit timeout
- **WHEN** a non-whitelisted command is encountered
- **AND** cplit is enabled
- **AND** cplit does not respond within the timeout period
- **THEN** the system SHALL fall back to local manual approval
- **AND** a notification SHALL be sent

### Requirement: Graceful degradation when cplit is unavailable

The system SHALL handle cplit server unavailability gracefully without blocking the workflow.

#### Scenario: cplit server unreachable
- **WHEN** cplit is enabled
- **AND** the cplit server is unreachable or returns an error
- **THEN** the system SHALL fall back to local manual approval
- **AND** a notification SHALL be sent
- **AND** no error SHALL be thrown that would disrupt Claude CLI

### Requirement: Whitelisted commands are not affected

Commands that match the whitelist SHALL continue to be auto-approved regardless of cplit configuration.

#### Scenario: Whitelisted command with cplit enabled
- **WHEN** a whitelisted command is encountered
- **AND** cplit is enabled
- **THEN** the command SHALL be auto-approved immediately
- **AND** cplit SHALL NOT be called
