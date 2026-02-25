## ADDED Requirements

### Requirement: Notification title includes project name prefix

All barnhk notifications SHALL display the project name as a prefix in the notification title when project name is available.

#### Scenario: Project name in title
- **WHEN** `send_notification` is called with project_name "cckit" and title "Claude Stopped"
- **THEN** the notification title SHALL be "[cckit] Claude Stopped"

#### Scenario: No project name when not provided
- **WHEN** `send_notification` is called without project_name parameter
- **THEN** the notification title SHALL NOT include a project name prefix

### Requirement: Project name extracted from cwd

Each hook that calls `send_notification` SHALL extract the project name from the `cwd` field using `basename` and pass it to `send_notification`.

#### Scenario: Hook passes project name
- **WHEN** a hook receives input with `cwd: "/Users/dev/projects/myapp"`
- **THEN** the hook SHALL pass "myapp" as the project_name parameter to `send_notification`

#### Scenario: Hook handles empty cwd
- **WHEN** a hook receives input without `cwd` field or with empty `cwd`
- **THEN** the hook SHALL pass empty string or omit the project_name parameter
