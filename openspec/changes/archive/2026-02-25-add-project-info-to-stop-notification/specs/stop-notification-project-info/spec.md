## ADDED Requirements

### Requirement: Stop notification displays project name

Stop hook SHALL display the project name extracted from the `cwd` field in the notification body.

#### Scenario: Project name shown from cwd
- **WHEN** Stop hook receives input with `cwd: "/Users/sujie/workspace/dev/apps/cckit"`
- **THEN** the notification body SHALL contain "📁 cckit"

#### Scenario: No project name when cwd is empty
- **WHEN** Stop hook receives input without `cwd` field or with empty `cwd`
- **THEN** the notification body SHALL NOT contain a project name line

### Requirement: Project name appears first in notification

Stop hook SHALL display the project name as the first line of the notification body.

#### Scenario: Project name before session ID
- **WHEN** Stop hook sends a notification with project name available
- **THEN** the project name line SHALL appear before the "Session:" line
