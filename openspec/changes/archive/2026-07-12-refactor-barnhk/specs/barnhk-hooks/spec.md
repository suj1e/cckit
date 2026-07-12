## ADDED Requirements

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

## REMOVED Requirements

### Requirement: plugin.json hook commands support cross-platform execution
**Reason**: PowerShell support is removed. `.sh` scripts are the single canonical format and work on all platforms (Windows via Git Bash bundled with Claude Code).

**Migration**: No action required. The `plugin.json` already references `.sh` paths as its canonical format.
