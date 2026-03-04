# Safe Commands Spec Delta

## ADDED Requirements

### Requirement: All openspec commands are safe
The system SHALL auto-approve any command starting with `openspec `.

#### Scenario: openspec instructions is auto-approved
- **WHEN** user runs `openspec instructions apply --change foo`
- **THEN** command is auto-approved without prompting

#### Scenario: openspec update is auto-approved
- **WHEN** user runs `openspec update`
- **THEN** command is auto-approved without prompting

### Requirement: Directory and file operations are safe
The system SHALL auto-approve common file system operations.

#### Scenario: mkdir is auto-approved
- **WHEN** user runs `mkdir -p src/components`
- **THEN** command is auto-approved without prompting

#### Scenario: touch is auto-approved
- **WHEN** user runs `touch src/newfile.txt`
- **THEN** command is auto-approved without prompting

#### Scenario: cp is auto-approved
- **WHEN** user runs `cp source.txt dest.txt`
- **THEN** command is auto-approved without prompting

#### Scenario: mv is auto-approved
- **WHEN** user runs `mv old.txt new.txt`
- **THEN** command is auto-approved without prompting

### Requirement: Docker read-only commands are safe
The system SHALL auto-approve Docker read-only and common development commands.

#### Scenario: docker ps is auto-approved
- **WHEN** user runs `docker ps -a`
- **THEN** command is auto-approved without prompting

#### Scenario: docker logs is auto-approved
- **WHEN** user runs `docker logs container-name`
- **THEN** command is auto-approved without prompting

#### Scenario: docker-compose up is auto-approved
- **WHEN** user runs `docker-compose up -d`
- **THEN** command is auto-approved without prompting

### Requirement: Claude updates docs before git push
Claude SHALL follow the workflow of updating documentation before pushing.

#### Scenario: Claude updates docs when asked to push
- **WHEN** user says "push" or "git push"
- **THEN** Claude checks README.md and CLAUDE.md for needed updates
- **AND** Claude updates docs if significant changes were made
- **AND** Claude stages and commits doc changes
- **AND** Claude proceeds with push

### Requirement: Project directory commands can be auto-approved
The system SHALL provide a toggle to auto-approve all commands within the project directory.

#### Scenario: project command auto-approve is enabled by default
- **WHEN** barnhk is installed
- **THEN** `AUTO_APPROVE_PROJECT_COMMANDS=true` is set in config

#### Scenario: commands in project directory are auto-approved when enabled
- **GIVEN** `AUTO_APPROVE_PROJECT_COMMANDS=true`
- **WHEN** a command is executed within the project directory
- **THEN** command is auto-approved without prompting

#### Scenario: project command auto-approve can be disabled
- **GIVEN** `AUTO_APPROVE_PROJECT_COMMANDS=false`
- **WHEN** a non-whitelisted command is executed
- **THEN** normal approval process is followed
