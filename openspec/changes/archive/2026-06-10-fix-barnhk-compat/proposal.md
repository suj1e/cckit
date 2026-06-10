## Why

barnhk hooks were written against an earlier Claude Code hooks spec. The latest spec (June 2026) has renamed input fields, changed output schemas, and added new events. Several hooks now read fields that no longer exist in the input JSON, causing silent failures — particularly `teammate-idle.sh` and `task-completed.sh` which read completely wrong field names.

## What Changes

- **TeammateIdle hook input**: Field names changed from `agent_name`/`agent_id` to `teammate_name`/`team_name`
- **TaskCompleted hook input**: Input schema changed from `{session_id, task}` to `{task_id, task_subject, task_description, teammate_name, team_name}`
- **Stop hook input**: `reason` field removed; new fields `stop_hook_active`, `last_assistant_message`, `background_tasks`, `session_crons` added
- **SessionEnd hook input**: New `reason` field added (clear/resume/logout/other)
- **PreToolUse output**: `denyReason` renamed to `permissionDecisionReason`; add `hookEventName: "PreToolUse"`
- **plugin.json hook format**: Shell-form `${CLAUDE_PLUGIN_ROOT}/lib/xxx.sh` → quoted `"${CLAUDE_PLUGIN_ROOT}"/lib/xxx.sh` per latest best practice

## Capabilities

### New Capabilities

_None_

### Modified Capabilities

- `barnhk-hooks`: Hook input/output schemas updated to match latest Claude Code hooks spec (June 2026). Field names, output format, and plugin.json hook definition format updated.

## Impact

- **Code**: `hooks/barnhk/lib/` — all 7 hook scripts and `plugin.json`
- **No API or dependency changes**: Pure bash script field-name and format updates
- **Backward compatibility**: These changes align with the current Claude Code runtime; old field names were already non-functional
