## 1. Core Implementation

- [x] 1.1 Modify `common.sh` `send_notification` to accept optional `project_name` parameter
- [x] 1.2 Prepend `[project_name]` to title when project_name is provided

## 2. Hook Updates

- [x] 2.1 Modify `stop.sh` to pass project_name and remove body-level project display
- [x] 2.2 Modify `notification.sh` to extract cwd and pass project_name
- [x] 2.3 Modify `session-end.sh` to extract cwd and pass project_name
- [x] 2.4 Modify `teammate-idle.sh` to extract cwd and pass project_name

## 3. Deployment

- [x] 3.1 Reinstall barnhk hooks to apply changes
- [x] 3.2 Update README.md and CLAUDE.md documentation
