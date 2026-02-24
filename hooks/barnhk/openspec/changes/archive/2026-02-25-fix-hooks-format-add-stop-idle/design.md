## Context

The barnhk hooks currently have an incorrect JSON format in settings.json. The `matcher` field should be a string regex (e.g., `"Bash"`) instead of an empty object `{}`. Additionally, the hooks only cover PreToolUse, PermissionRequest, and TaskCompleted events, missing Stop and TeammateIdle events that would be useful for session lifecycle notifications.

## Goals / Non-Goals

**Goals:**
- Fix hook configuration format to use string regex for matcher
- Add Stop hook for session end notifications
- Add TeammateIdle hook for teammate idle notifications
- Maintain backward compatibility with existing config files

**Non-Goals:**
- Changing hook script logic
- Adding new dangerous/safe command patterns
- Modifying Bark notification API integration

## Decisions

### 1. Hook Format Correction
**Decision**: Use `"Bash"` as matcher string for PreToolUse and PermissionRequest hooks
**Rationale**: The official Claude Code hooks documentation specifies matcher as a regex string that matches tool names. `"Bash"` will match BashTool invocations.
**Alternative**: Could use `"BashTool"` but `"Bash"` is the standard pattern shown in docs.

### 2. TaskCompleted and Stop/TeammateIdle Format
**Decision**: These hooks do NOT have a matcher field
**Rationale**: According to docs, TaskCompleted, Stop, and similar lifecycle events don't support matchers - they fire for all events of that type.

### 3. Stop Hook Script
**Decision**: Create `stop.sh` that sends Bark notification with session summary
**Rationale**: Provides visibility when Claude stops, similar to TaskCompleted.

### 4. TeammateIdle Hook Script
**Decision**: Create `teammate-idle.sh` that sends Bark notification with teammate info
**Rationale**: Useful for team coordination when using agent teams feature.

## Risks / Trade-offs

- **Risk**: Existing users need to re-run install.sh to get fixed format
  - **Mitigation**: Document that reinstall is required; install.sh is idempotent

- **Risk**: Stop and TeammateIdle hooks may fire frequently in some workflows
  - **Mitigation**: Users can disable by commenting out in config or uninstalling
