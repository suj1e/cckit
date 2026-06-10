## Context

barnhk hooks (`hooks/barnhk/lib/`) were written against an early Claude Code hooks spec snapshot. The hooks runtime has since evolved — input field names have changed (e.g., `agent_name` → `teammate_name`), output schemas have been refined (e.g., `denyReason` → `permissionDecisionReason`), and the recommended plugin.json format has been updated. Several hooks currently read fields that no longer exist in the JSON input, causing silent no-op failures.

All changes are scoped to `hooks/barnhk/` — bash scripts and `plugin.json`. No new dependencies.

## Goals / Non-Goals

**Goals:**
- Fix all hooks that read incorrect input field names so they work with the current Claude Code runtime
- Align output JSON format with the latest spec (correct field names, include `hookEventName`)
- Update `plugin.json` hook definitions to use the recommended quoted path format
- Improve notification content by using newly available input fields (e.g., `task_subject`, `teammate_name`)

**Non-Goals:**
- Adding new hook events (e.g., `StopFailure`, `PostToolBatch`, `MessageDisplay`)
- Updating `standards/` spec documents to the latest version
- Refactoring the notification pipeline or adding new channels
- Using new features like `userConfig`, `updatedInput`, `updatedPermissions`

## Decisions

### 1. TeammateIdle: read `teammate_name` + `team_name` (not `agent_name` + `agent_id`)

**Rationale**: The spec changed these fields completely. The old fields are never present in the input JSON, so the current hook silently does nothing useful. Extract both new fields and include them in notification body.

**Alternative considered**: Keep reading old fields as fallback. Rejected — old fields are never sent, so fallback code is dead code.

### 2. TaskCompleted: adopt full new input schema

**Rationale**: The input changed from `{session_id, task}` to `{task_id, task_subject, task_description, teammate_name, team_name}`. Extract all available fields and include relevant ones in notification body for richer context.

### 3. Stop hook: use `last_assistant_message` instead of `reason`

**Rationale**: The Stop event no longer sends `reason`. Instead it provides `stop_hook_active`, `last_assistant_message`, `background_tasks`, and `session_crons`. The hook only uses the event for notification — extract `last_assistant_message` as the primary content.

### 4. PreToolUse output: use `permissionDecisionReason` and add `hookEventName`

**Rationale**: The spec renamed `denyReason` to `permissionDecisionReason`. Adding `hookEventName: "PreToolUse"` follows the documented pattern. Both changes are cosmetic but align with the spec.

### 5. plugin.json: quote `${CLAUDE_PLUGIN_ROOT}` in shell-form commands

**Rationale**: The latest docs recommend wrapping the placeholder in double quotes for shell-form hooks: `"${CLAUDE_PLUGIN_ROOT}"/lib/xxx.sh`. This prevents breakage if the plugin root path ever contains spaces.

### 6. SessionEnd: extract `reason` field

**Rationale**: The spec now provides a `reason` field (clear/resume/logout/prompt_input_exit/bypass_permissions_disabled/other). Including it in the notification adds useful context.

## Risks / Trade-offs

- **[Spec could change again]** → Changes are minimal and well-documented. Each fix maps 1:1 to a spec field, making future updates straightforward.
- **[Quoted path format may break older Claude Code versions]** → The quoted format is backward-compatible; it's purely defensive quoting that bash handles correctly in all versions.
- **[No automated testing for hooks]** → Verification relies on reinstalling (`./uninstall.sh barnhk && ./install.sh barnhk`) and manual testing. This is the existing workflow.
