## ADDED Requirements

### Requirement: Hooks use correct exit codes

All hooks SHALL use exit code 2 for blocking operations, not exit code 1.

#### Scenario: Block dangerous command

- **WHEN** PreToolUse detects a critical or high-danger command
- **THEN** it exits with code 2
- **AND** NOT with code 1

#### Scenario: Allow safe operation

- **WHEN** hook allows the operation to proceed
- **THEN** it exits with code 0

### Requirement: Exit code semantics

Exit codes SHALL follow Claude Code official specification.

#### Scenario: Exit code 0 means allow

- **WHEN** hook exits with code 0
- **THEN** Claude Code proceeds with the operation

#### Scenario: Exit code 2 means block

- **WHEN** hook exits with code 2
- **THEN** Claude Code blocks the operation
- **AND** displays the error message
