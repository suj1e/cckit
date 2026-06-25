# barnhk-powershell-hooks

PowerShell implementation of barnhk hooks for Windows. All hooks use zero external dependencies (PowerShell 5.1+ built-in only).

## Requirements

### Requirement: PreToolUse hook detects dangerous commands
The PowerShell PreToolUse hook SHALL read JSON from stdin, extract `tool_name` and `tool_input.command`, and determine danger level. SHALL output `hookSpecificOutput` JSON with `permissionDecision: "deny"` and `permissionDecisionReason` for critical/high danger commands, then exit with code 2. SHALL exit 0 for safe commands.

#### Scenario: Block critical danger command
- **WHEN** input contains `{"tool_name": "Bash", "tool_input": {"command": "rm -rf /"}}`
- **THEN** hook outputs deny JSON and exits 2

#### Scenario: Block high danger command
- **WHEN** input contains `{"tool_name": "Bash", "tool_input": {"command": "sudo rm important"}}`
- **THEN** hook outputs deny JSON and exits 2

#### Scenario: Allow safe command
- **WHEN** input contains `{"tool_name": "Bash", "tool_input": {"command": "git status"}}`
- **THEN** hook exits 0 with no output

#### Scenario: Non-Bash tool is skipped
- **WHEN** input contains `{"tool_name": "Read", "tool_input": {"path": "/some/file"}}`
- **THEN** hook exits 0 with no output

### Requirement: PermissionRequest hook auto-approves safe commands
The PowerShell PermissionRequest hook SHALL auto-approve commands matching the safe whitelist and Edit/Write operations within the project directory. SHALL output `{"hookSpecificOutput": {"hookEventName": "PermissionRequest", "decision": {"behavior": "allow"}}}` for auto-approved operations. SHALL exit 0 without output for non-whitelisted commands (letting user decide).

#### Scenario: Auto-approve git status
- **WHEN** input contains `{"tool_name": "Bash", "tool_input": {"command": "git status"}}` and `cwd` is inside project
- **THEN** hook outputs allow JSON with `decision.behavior: "allow"`

#### Scenario: Auto-approve Edit within project
- **WHEN** input contains `{"tool_name": "Edit", "tool_input": {"file_path": "D:/projects/foo/src/main.ts"}}` and `cwd` is `D:/projects/foo`
- **THEN** hook outputs allow JSON

#### Scenario: Non-whitelisted command requires manual approval
- **WHEN** input contains `{"tool_name": "Bash", "tool_input": {"command": "deploy-to-prod.sh"}}`
- **THEN** hook exits 0 with no output

### Requirement: Notification hook sends multi-channel notifications
The PowerShell Notification hook SHALL extract `notification_type`, `message`, `session_id`, `cwd`, `transcript_path` from input JSON. SHALL honor notification mode (skip/default/transcript) from config. SHALL send notifications via configured channels (Bark/Discord/Feishu).

#### Scenario: Skip permission_prompt notification
- **WHEN** `notification_type` is `permission_prompt` and config mode is `skip`
- **THEN** hook exits 0 without sending any notification

#### Scenario: Extract transcript content for question
- **WHEN** `notification_type` is `question` and mode is `transcript`
- **THEN** hook reads transcript file, extracts latest assistant message text, and includes it in notification body

#### Scenario: Fallback to default message
- **WHEN** transcript extraction fails or mode is `default`
- **THEN** hook uses the `message` field as notification content

### Requirement: TaskCompleted hook sends completion notification
The PowerShell TaskCompleted hook SHALL extract `task_id`, `task_subject`, `task_description`, `teammate_name`, `team_name` from input JSON and send notification via configured channels.

#### Scenario: Task completed with full fields
- **WHEN** input contains task subject and task ID
- **THEN** notification body includes task subject and task ID

#### Scenario: Task completed with minimal fields
- **WHEN** input contains only `task_id`
- **THEN** hook sends notification with available fields, omits missing ones

### Requirement: Stop hook sends session stop notification
The PowerShell Stop hook SHALL extract `session_id`, `last_assistant_message`, `cwd` from input JSON and send notification.

#### Scenario: Normal stop with assistant message
- **WHEN** input contains `last_assistant_message: "Done refactoring"`
- **THEN** notification body includes the truncated assistant message

### Requirement: SessionEnd hook sends session end notification
The PowerShell SessionEnd hook SHALL extract `session_id`, `reason`, `cwd` from input JSON and send notification.

#### Scenario: Session ends normally
- **WHEN** input contains `{"reason": "other"}`
- **THEN** notification includes the end reason

### Requirement: TeammateIdle hook sends idle notification
The PowerShell TeammateIdle hook SHALL extract `teammate_name`, `team_name` from input JSON and send notification.

#### Scenario: Teammate goes idle
- **WHEN** input contains `{"teammate_name": "researcher", "team_name": "my-project"}`
- **THEN** notification body includes teammate name and team name

### Requirement: PowerShell config module loads barnhk settings
The `barnhk.psd1` config SHALL define hashtable with all configurable settings: notification URLs, notification titles, notification type modes, auto-approve toggle, safe commands whitelist, and debug toggle. The `common.psm1` module SHALL import this config and expose settings to all hook scripts.

#### Scenario: Config file loaded by common module
- **WHEN** `common.psm1` is imported by a hook script
- **THEN** `barnhk.psd1` is parsed and all config values are available as module variables

### Requirement: All PowerShell hooks use zero external dependencies
All PowerShell hook scripts SHALL use only PowerShell built-in cmdlets and operators. SHALL NOT require `jq`, `curl`, `tac`, or any third-party tools.

#### Scenario: No external tool dependency
- **WHEN** hooks run on a fresh Windows 10/11 installation with only PowerShell 5.1
- **THEN** all hooks function correctly without installing additional software
