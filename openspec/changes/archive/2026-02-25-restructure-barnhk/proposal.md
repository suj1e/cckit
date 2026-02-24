## Why

Current barnhk directory structure is flat with all files at the same level. The install.sh has issues with idempotency (repeated installs create duplicate hooks) and uninstall.sh uses exact path matching which may miss cleanup. A cleaner structure and improved scripts will enhance maintainability and user experience.

## What Changes

- **BREAKING** Restructure directory: move hook scripts and config to `lib/` subdirectory
- Move install.sh, uninstall.sh, README.md to root level for better discoverability
- Make install.sh idempotent - remove existing barnhk hooks before adding new ones
- Improve uninstall.sh to match hooks by path pattern (not exact match)
- Update all script paths to reflect new directory structure

## Capabilities

### New Capabilities

(None - this is a refactoring task)

### Modified Capabilities

- `safe-command-auto-approval`: Script path changes from root to `lib/`, install behavior changes to idempotent

## Impact

- **File moves:**
  - `common.sh` → `lib/common.sh`
  - `pre-tool-use.sh` → `lib/pre-tool-use.sh`
  - `permission-request.sh` → `lib/permission-request.sh`
  - `task-completed.sh` → `lib/task-completed.sh`
  - `barnhk.conf` → `lib/barnhk.conf`
- **Scripts updated:** install.sh, uninstall.sh to use new paths and improved logic
- **Users need to re-run install.sh** after update for hooks to work with new paths
