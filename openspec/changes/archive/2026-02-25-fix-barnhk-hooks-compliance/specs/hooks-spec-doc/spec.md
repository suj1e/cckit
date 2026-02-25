## ADDED Requirements

### Requirement: Hooks specification document exists

The project SHALL include a Claude Code hooks specification document for reference.

#### Scenario: Document location

- **WHEN** developer needs to reference hooks specification
- **THEN** document is available at `standards/hooks/claude-code-hooks.md`

### Requirement: Specification document content

The hooks specification document SHALL contain all hook types and their input/output formats.

#### Scenario: Hook types documented

- **WHEN** reading the specification
- **THEN** all hook types are listed (PreToolUse, PermissionRequest, TaskCompleted, etc.)
- **AND** each hook has input JSON schema documented
- **AND** each hook has output format documented

#### Scenario: Exit codes documented

- **WHEN** reading the specification
- **THEN** exit code semantics are clearly documented (0=allow, 2=block)

### Requirement: Specification document format

The hooks specification document SHALL be in Markdown format for easy reading and editing.

#### Scenario: Markdown format

- **WHEN** viewing the document
- **THEN** it renders correctly as Markdown
- **AND** includes code examples for JSON input/output
