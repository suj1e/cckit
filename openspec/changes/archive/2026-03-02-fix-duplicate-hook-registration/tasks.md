## 1. Remove duplicate hook registration

- [x] 1.1 Remove `merge_hooks()` function from `install.sh`
- [x] 1.2 Remove call to `merge_hooks()` in `install_plugin()`
- [x] 1.3 Keep `ensure_marketplace()` function

## 2. Clean up uninstall.sh

- [x] 2.1 Remove any hook cleanup logic from `uninstall.sh`

## 3. Fix idle_prompt transcript extraction

- [x] 3.1 Debug why `idle_prompt` shows generic content instead of transcript
- [x] 3.2 Add debug logging to `extract_transcript_content()` function
- [x] 3.3 Fix the extraction logic if needed
- [x] 3.4 Verify notifications show transcript content (manual verification required)

## 4. Reinstall and verify

- [x] 4.1 Reinstall barnhk plugin: `./uninstall.sh barnhk && ./install.sh barnhk`
- [x] 4.2 Trigger idle_prompt and verify transcript extraction works (manual verification required)
- [x] 4.3 Verify only one notification is sent per trigger (manual verification required)

## 5. Documentation

- [x] 5.1 Update README.md - remove "register hooks to settings.json" reference
- [x] 5.2 Update hooks/barnhk/README.md - add debug logging documentation
- [x] 5.3 Update CLAUDE.md - add debug logging info, clarify hook loading mechanism

## 6. AskUserQuestion notification support (investigation)

- [x] 6.1 Research if AskUserQuestion triggers PreToolUse hook
- [x] 6.2 Research if AskUserQuestion triggers Notification hook with `question` type
- [x] 6.3 Document findings: **AskUserQuestion does not trigger any hooks** - this is a Claude Code limitation

### Findings

**AskUserQuestion hook support:**
- PreToolUse hook: NOT triggered (only Bash commands observed)
- Notification hook with `question` type: NOT triggered (only `permission_prompt` observed)

**Workaround options:**
- None currently available - this is a limitation of Claude Code's hook system
- Future: Monitor for Claude Code updates that may add hook support for AskUserQuestion
