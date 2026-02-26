## ADDED Requirements

### Requirement: Auto-approve openspec commands

The system SHALL automatically approve openspec workflow commands without user confirmation.

#### Scenario: Approve openspec list
- **WHEN** permission is requested for `openspec list`
- **THEN** the hook SHALL output approval JSON and exit 0

#### Scenario: Approve openspec propose
- **WHEN** permission is requested for `openspec propose`
- **THEN** the hook SHALL auto-approve

#### Scenario: Approve openspec apply
- **WHEN** permission is requested for `openspec apply`
- **THEN** the hook SHALL auto-approve

#### Scenario: Approve openspec archive
- **WHEN** permission is requested for `openspec archive`
- **THEN** the hook SHALL auto-approve

#### Scenario: Approve openspec explore
- **WHEN** permission is requested for `openspec explore`
- **THEN** the hook SHALL auto-approve

#### Scenario: Approve openspec status
- **WHEN** permission is requested for `openspec status`
- **THEN** the hook SHALL auto-approve

#### Scenario: Approve openspec init
- **WHEN** permission is requested for `openspec init`
- **THEN** the hook SHALL auto-approve

#### Scenario: Do not auto-approve unknown openspec subcommands
- **WHEN** permission is requested for `openspec unknown-command`
- **THEN** the hook SHALL NOT auto-approve and require user confirmation
