## 1. Fix TeammateIdle hook

- [x] 1.1 Update `teammate-idle.sh`: change `agent_name` → `teammate_name` and `agent_id` → `team_name` in jq extraction
- [x] 1.2 Update notification body to show `teammate_name` and `team_name`

## 2. Fix TaskCompleted hook

- [x] 2.1 Update `task-completed.sh`: replace `task` string extraction with `task_id`, `task_subject`, `task_description`, `teammate_name`, `team_name`
- [x] 2.2 Update notification body to include task subject and task ID

## 3. Fix Stop hook

- [x] 3.1 Update `stop.sh`: remove `reason` extraction, add `last_assistant_message` extraction
- [x] 3.2 Update notification body to use assistant message content

## 4. Fix SessionEnd hook

- [x] 4.1 Update `session-end.sh`: add `reason` field extraction from input JSON
- [x] 4.2 Update notification body to include session end reason

## 5. Fix PreToolUse hook output format

- [x] 5.1 Update `pre-tool-use.sh`: rename `denyReason` → `permissionDecisionReason` in jq output
- [x] 5.2 Add `hookEventName: "PreToolUse"` to the output JSON

## 6. Update plugin.json hook path format

- [x] 6.1 Update all hook `command` fields in `plugin.json` to use quoted format: `"${CLAUDE_PLUGIN_ROOT}"/lib/xxx.sh`

## 7. Verify

- [x] 7.1 Reinstall barnhk: `./uninstall.sh barnhk && ./install.sh barnhk`
- [x] 7.2 Verify plugin loads without errors via `claude plugin list`
