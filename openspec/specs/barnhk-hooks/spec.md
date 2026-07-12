## MODIFIED Requirements

### Requirement: TeammateIdle hook reads correct input fields
The TeammateIdle hook SHALL extract `teammate_name` and `team_name` from the input JSON. It SHALL NOT depend on `agent_name` or `agent_id` fields. The notification body SHALL include the teammate name and team name.

#### Scenario: Teammate goes idle
- **WHEN** Claude Code sends a TeammateIdle event with `{"teammate_name": "researcher", "team_name": "my-project"}`
- **THEN** the hook extracts `teammate_name` as "researcher" and `team_name` as "my-project" and includes both in the notification body

#### Scenario: Fields absent
- **WHEN** Claude Code sends a TeammateIdle event without `teammate_name` or `team_name`
- **THEN** the hook falls back to "Unknown" for missing fields and still sends the notification

### Requirement: TaskCompleted hook reads correct input fields
The TaskCompleted hook SHALL extract `task_id`, `task_subject`, `task_description`, `teammate_name`, and `team_name` from the input JSON. It SHALL NOT depend on a `task` string field. The notification body SHALL include task subject and task ID.

#### Scenario: Task completed with full fields
- **WHEN** Claude Code sends a TaskCompleted event with `{"task_id": "1", "task_subject": "Fix auth", "task_description": "Add JWT", "teammate_name": "dev", "team_name": "backend"}`
- **THEN** the hook extracts all fields and includes task subject and ID in the notification

#### Scenario: Task completed with minimal fields
- **WHEN** Claude Code sends a TaskCompleted event with only `task_id` and `task_subject`
- **THEN** the hook uses fallback values for absent optional fields and still sends the notification

### Requirement: Stop hook uses current input schema
The Stop hook SHALL extract `last_assistant_message` from the input JSON for notification content. It SHALL NOT depend on a `reason` field in the Stop event input. The hook MAY extract `stop_hook_active` to avoid redundant notifications.

#### Scenario: Normal stop with assistant message
- **WHEN** Claude Code sends a Stop event with `{"stop_hook_active": false, "last_assistant_message": "Done refactoring"}`
- **THEN** the hook sends a notification including the assistant message content

#### Scenario: Stop hook already active
- **WHEN** Claude Code sends a Stop event with `{"stop_hook_active": true}`
- **THEN** the hook still sends the notification (no special behavior needed)

### Requirement: PreToolUse output uses correct field names
The PreToolUse hook SHALL output `permissionDecisionReason` (not `denyReason`) in the `hookSpecificOutput` JSON when denying a command. The output SHALL include `hookEventName: "PreToolUse"`.

#### Scenario: Blocking a critical command
- **WHEN** the hook detects a critical dangerous command (e.g., `rm -rf /`)
- **THEN** the output JSON contains `{"hookSpecificOutput": {"hookEventName": "PreToolUse", "permissionDecision": "deny", "permissionDecisionReason": "..."}}`

#### Scenario: Allowing a safe command
- **WHEN** the hook detects a safe command
- **THEN** the hook exits with code 0 and no output

### Requirement: SessionEnd hook extracts reason field
The SessionEnd hook SHALL extract the `reason` field from the input JSON. The notification body SHALL include the session end reason (clear/resume/logout/other).

#### Scenario: Session ends normally
- **WHEN** Claude Code sends a SessionEnd event with `{"reason": "other"}`
- **THEN** the hook sends a notification including the reason

#### Scenario: Session ends via logout
- **WHEN** Claude Code sends a SessionEnd event with `{"reason": "logout"}`
- **THEN** the notification body indicates the session ended due to logout

## ADDED Requirements

### Requirement: plugin.json hook commands use quoted path format
All hook `command` fields in `plugin.json` SHALL wrap `${CLAUDE_PLUGIN_ROOT}` in double quotes using the format `"${CLAUDE_PLUGIN_ROOT}"/lib/script.sh` to handle paths with spaces or special characters.

#### Scenario: Hook command path resolution
- **WHEN** Claude Code loads the plugin and resolves hook commands
- **THEN** each command string uses the format `"${CLAUDE_PLUGIN_ROOT}"/lib/xxx.sh` with quoted placeholder

### Requirement: dispatch_hook pattern
Each hook entry script SHALL use a `dispatch_hook "<name>"` pattern where `dispatch_hook` handles `load_config`, stdin reading, `PROJECT_NAME` extraction, and dispatching to `hook_<name>` functions in `hooks.sh`.

#### Scenario: Hook entry script
- **WHEN** a hook event fires
- **THEN** the entry script sources `common.sh` and calls `dispatch_hook "<event-name>"`
- **AND** the entry script is no more than 6 lines

### Requirement: common.sh is split into single-responsibility modules
The common.sh functionality SHALL be split into separate files by responsibility: `hooks.sh` (hook logic), `notify.sh` (notification backends), `safety.sh` (command safety checks), `transcript.sh` (transcript extraction). `common.sh` SHALL serve as the entry point that sources all sub-modules.

#### Scenario: Module separation
- **WHEN** a developer needs to modify notification logic
- **THEN** they only need to edit `notify.sh` without touching safety checks or hook logic

### Requirement: barnhk is bash-only
The barnhk plugin SHALL contain only bash (`.sh`) scripts. All PowerShell (`.ps1`, `.psm1`, `.psd1`) files SHALL be removed. The `plugin.json` SHALL continue referencing `.sh` paths.

#### Scenario: Plugin installation on any platform
- **WHEN** barnhk is installed on any OS
- **THEN** only `.sh` hook scripts exist for execution
