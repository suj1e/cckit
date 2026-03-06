# Upd Skill Spec

## ADDED Requirements

### Requirement: Skill updates README.md and CLAUDE.md
The system SHALL update README.md and CLAUDE.md files when they exist in the project.

#### Scenario: Update README.md when it exists
- **GIVEN** project has README.md file
- **WHEN** user invokes `/upd`
- **THEN** README.md is analyzed and updated based on recent changes

#### Scenario: Update CLAUDE.md when it exists
- **GIVEN** project has CLAUDE.md file
- **WHEN** user invokes `/upd`
- **THEN** CLAUDE.md is analyzed and updated based on recent changes

#### Scenario: Skip non-existent files
- **GIVEN** project does not have CLAUDE.md
- **WHEN** user invokes `/upd`
- **THEN** only README.md is updated (if exists)
- **AND** no error is raised for missing CLAUDE.md

### Requirement: Configurable all-md mode
The system SHALL support a configuration option to update all .md files in the project.

#### Scenario: Default mode updates only core docs
- **GIVEN** `UPD_TARGET_ALL_MD` is not set or set to `false`
- **WHEN** user invokes `/upd`
- **THEN** only README.md and CLAUDE.md are updated

#### Scenario: Extended mode updates all markdown files
- **GIVEN** `UPD_TARGET_ALL_MD=true`
- **WHEN** user invokes `/upd`
- **THEN** all .md files in project are considered for update
- **AND** node_modules/, .git/, and archive/ directories are excluded

### Requirement: Auto commit and push
The system SHALL automatically commit and push documentation changes.

#### Scenario: Commit and push when changes are made
- **GIVEN** documentation was updated
- **WHEN** updates are complete
- **THEN** changes are staged with `git add`
- **AND** changes are committed with message `docs: update documentation`
- **AND** changes are pushed to remote

#### Scenario: Skip commit when no changes
- **GIVEN** no documentation updates were needed
- **WHEN** analysis is complete
- **THEN** user is notified "No documentation updates needed"
- **AND** no commit or push is performed

### Requirement: Change detection
The system SHALL detect recent code changes to inform documentation updates.

#### Scenario: Analyze git history
- **WHEN** user invokes `/upd`
- **THEN** `git status` is checked
- **AND** recent commits are reviewed via `git log`
- **AND** recent file changes are analyzed via `git diff`
