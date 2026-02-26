## MODIFIED Requirements

### Requirement: Project name extracted from cwd

Each hook that calls `send_notification` SHALL extract the project name using a fallback mechanism and pass it to `send_notification`.

#### Scenario: Hook passes project name from cwd
- **WHEN** a hook receives input with `cwd: "/Users/dev/projects/myapp"`
- **THEN** the hook SHALL pass "myapp" as the project_name parameter to `send_notification`

#### Scenario: Hook uses PWD fallback when cwd is empty
- **WHEN** a hook receives input without `cwd` field or with empty `cwd`
- **AND** the current working directory is `/Users/dev/projects/otherapp`
- **THEN** the hook SHALL pass "otherapp" as the project_name parameter to `send_notification`

## ADDED Requirements

### Requirement: All notification types include project name

All hooks that send notifications SHALL include project name in the notification title, including:
- `pre-tool-use.sh` (claude-danger)
- `permission-request.sh` (claude-permit)
- `task-completed.sh` (claude-done)

#### Scenario: Danger notification includes project name
- **WHEN** pre-tool-use.sh blocks a dangerous command
- **THEN** the notification title SHALL include project name prefix

#### Scenario: Permit notification includes project name
- **WHEN** permission-request.sh auto-approves or requires manual approval
- **THEN** the notification title SHALL include project name prefix

#### Scenario: Done notification includes project name
- **WHEN** task-completed.sh sends completion notification
- **THEN** the notification title SHALL include project name prefix
