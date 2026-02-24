## 1. Directory Restructure

- [x] 1.1 Create `hooks/barnhk/lib/` directory
- [x] 1.2 Move `common.sh` to `lib/common.sh`
- [x] 1.3 Move `pre-tool-use.sh` to `lib/pre-tool-use.sh`
- [x] 1.4 Move `permission-request.sh` to `lib/permission-request.sh`
- [x] 1.5 Move `task-completed.sh` to `lib/task-completed.sh`
- [x] 1.6 Move `barnhk.conf` to `lib/barnhk.conf`

## 2. Update Script Paths

- [x] 2.1 Update `lib/common.sh` to source config from correct relative path
- [x] 2.2 Update `lib/pre-tool-use.sh` to source common.sh from correct path
- [x] 2.3 Update `lib/permission-request.sh` to source common.sh from correct path
- [x] 2.4 Update `lib/task-completed.sh` to source common.sh from correct path

## 3. Improve Install Script

- [x] 3.1 Update install.sh to reference scripts in `lib/` subdirectory
- [x] 3.2 Add uninstall logic at the start of install.sh for idempotent installation
- [x] 3.3 Update output messages to reflect new structure

## 4. Improve Uninstall Script

- [x] 4.1 Update uninstall.sh to match hooks by "barnhk" path pattern instead of exact path
- [x] 4.2 Update uninstall.sh to reference scripts in `lib/` subdirectory

## 5. Cleanup

- [x] 5.1 Remove old script files from root directory (if any remain)
- [x] 5.2 Verify all scripts are executable
