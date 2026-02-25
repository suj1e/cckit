## 1. Create Standards Document

- [x] 1.1 Create `standards/hooks/claude-code-hooks.md` with official hooks specification
- [x] 1.2 Update CLAUDE.md to reference standards/hooks/ with strict compliance requirement

## 2. Fix JSON Paths in PreToolUse

- [x] 2.1 Update pre-tool-use.sh: change `.tool` to `.tool_name`
- [x] 2.2 Update pre-tool-use.sh: change `.input.command` to `.tool_input.command`

## 3. Fix JSON Paths in PermissionRequest

- [x] 3.1 Update permission-request.sh: change `.permission.name` to `.tool_name`
- [x] 3.2 Update permission-request.sh: change `.permission.command` to `.tool_input.command`
- [x] 3.3 Update permission-request.sh: change `.permission.path` to `.tool_input.path`

## 4. Fix Exit Codes

- [x] 4.1 Update pre-tool-use.sh: change `exit 1` to `exit 2` for blocking

## 5. Fix PreToolUse Output Format

- [x] 5.1 Update pre-tool-use.sh: output structured JSON with hookSpecificOutput
- [x] 5.2 Update pre-tool-use.sh: move decision output to stdout

## 6. Add SessionEnd Hook

- [x] 6.1 Create session-end.sh hook script
- [x] 6.2 Update install.sh to register SessionEnd hook
- [x] 6.3 Update README.md with SessionEnd hook documentation

## 7. Testing and Validation

- [x] 7.1 Test PreToolUse with dangerous command (verify block with exit 2)
- [x] 7.2 Test PermissionRequest with safe command (verify auto-approve)
- [x] 7.3 Test SessionEnd hook triggers correctly
