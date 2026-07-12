## REMOVED Requirements

### Requirement: EchoBell webhook notification
**Reason**: Hook 内做网络 I/O 导致并行子进程泄漏，不符合官方最佳实践。通知功能已完全移除。

### Requirement: (implicit) Bark notification support
**Reason**: 通知功能已完全移除。

### Requirement: (implicit) Discord notification support
**Reason**: 通知功能已完全移除。

### Requirement: (implicit) Feishu notification support
**Reason**: 通知功能已完全移除。

## MODIFIED Requirements

### Requirement: TeammateIdle hook reads correct input fields
The TeammateIdle hook SHALL extract `teammate_name` and `team_name` from the input JSON. It SHALL NOT depend on `agent_name` or `agent_id` fields.

#### Scenario: Teammate goes idle
- **WHEN** Claude Code sends a TeammateIdle event with `{"teammate_name": "researcher", "team_name": "my-project"}`
- **THEN** the hook extracts `teammate_name` as "researcher" and `team_name` as "my-project"

#### Scenario: Fields absent
- **WHEN** Claude Code sends a TeammateIdle event without `teammate_name` or `team_name`
- **THEN** the hook exits cleanly

### Requirement: TaskCompleted hook reads correct input fields
The TaskCompleted hook SHALL extract `task_id`, `task_subject`, `task_description`, `teammate_name`, and `team_name` from the input JSON. It SHALL NOT depend on a `task` string field.

#### Scenario: Task completed with full fields
- **WHEN** Claude Code sends a TaskCompleted event with `{"task_id": "1", "task_subject": "Fix auth", "task_description": "Add JWT", "teammate_name": "dev", "team_name": "backend"}`
- **THEN** the hook extracts all fields and exits cleanly

#### Scenario: Task completed with minimal fields
- **WHEN** Claude Code sends a TaskCompleted event with only `task_id` and `task_subject`
- **THEN** the hook exits cleanly

### Requirement: Stop hook uses current input schema
The Stop hook SHALL extract `last_assistant_message` from the input JSON. It SHALL NOT depend on a `reason` field in the Stop event input.

#### Scenario: Normal stop with assistant message
- **WHEN** Claude Code sends a Stop event with `{"stop_hook_active": false, "last_assistant_message": "Done refactoring"}`
- **THEN** the hook exits cleanly

#### Scenario: Stop hook already active
- **WHEN** Claude Code sends a Stop event with `{"stop_hook_active": true}`
- **THEN** the hook exits cleanly

### Requirement: SessionEnd hook extracts reason field
The SessionEnd hook SHALL extract the `reason` field from the input JSON.

#### Scenario: Session ends normally
- **WHEN** Claude Code sends a SessionEnd event with `{"reason": "other"}`
- **THEN** the hook exits cleanly

#### Scenario: Session ends via logout
- **WHEN** Claude Code sends a SessionEnd event with `{"reason": "logout"}`
- **THEN** the hook exits cleanly

### Requirement: common.sh is split into single-responsibility modules
The common.sh functionality SHALL be split into separate files by responsibility: `hooks.sh` (hook logic) and `safety.sh` (command safety checks). `common.sh` SHALL serve as the entry point that sources the sub-modules. Notification and transcript modules SHALL be removed.

#### Scenario: Module separation
- **WHEN** a developer needs to modify safety logic
- **THEN** they only need to edit `safety.sh` without touching hook logic

## ADDED Requirements

### Requirement: Hooks have zero side effects
The barnhk hook functions SHALL NOT perform any network I/O, background process spawning, or filesystem writes outside of configuration loading. Hooks are pure decision-making functions that return JSON output and exit codes.

#### Scenario: Hook execution
- **WHEN** any barnhk hook is triggered
- **THEN** the hook only reads input JSON, performs safety checks, and returns a decision
- **AND** no network requests, file writes, or background processes are created

### Requirement: Hooks set explicit timeout
All hook handlers in `plugin.json` SHALL include `"timeout": 10` to prevent abnormal blocking.

#### Scenario: Hook timeout
- **WHEN** a hook script hangs or exceeds normal execution time
- **THEN** Claude Code terminates the hook after 10 seconds
