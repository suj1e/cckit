## 1. Split common.sh

- [x] 1.1 Extract `is_safe_command` + `check_danger_level` → `lib/safety.sh`
- [x] 1.2 Extract `send_notification` + 3 backends → `lib/notify.sh`
- [x] 1.3 Extract `extract_transcript_content` → `lib/transcript.sh`
- [x] 1.4 Rewrite `lib/common.sh` as entry point: source sub-modules + `dispatch_hook` + utility functions

## 2. Implement dispatch_hook + hook functions

- [x] 2.1 Create `lib/hooks.sh` with 7 `hook_*` functions (move logic from entry scripts)
- [x] 2.2 Implement `dispatch_hook` in `common.sh`
- [x] 2.3 Merge `critical`/`high` duplicate branches in `hook_pre_tool_use`
- [x] 2.4 Rewrite 7 entry scripts to 5-line `dispatch_hook` pattern

## 3. Delete PowerShell files

- [x] 3.1 Delete all `.ps1` files (7 hook entry scripts)
- [x] 3.2 Delete `common.psm1` and `barnhk.psd1`

## 4. Add tests

- [x] 4.1 Create `tests/test-safety.sh` — danger level checks + safe command whitelist
- [x] 4.2 Create `tests/test-notify.sh` — dry-run payload construction
- [x] 4.3 Create `tests/test-hooks.sh` — hook input parsing + output format

## 5. Update documentation

- [x] 5.1 Update `CLAUDE.md` — remove PowerShell cross-platform development section
- [x] 5.2 Update `hooks/barnhk/README.md` — reflect new file structure

## 6. Verify

- [x] 6.1 Run all test scripts
- [x] 6.2 Test `node bin/cli.js install barnhk` installs correctly
- [x] 6.3 Trigger a blocked command to verify PreToolUse still works
- [x] 6.4 Verify `npm pack` includes new files and excludes `.ps1`
