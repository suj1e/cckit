## 1. Create New Hook Scripts

- [x] 1.1 Create lib/stop.sh script for Stop hook notifications
- [x] 1.2 Create lib/teammate-idle.sh script for TeammateIdle hook notifications
- [x] 1.3 Add TITLE_STOP and TITLE_IDLE config keys to barnhk.conf

## 2. Fix Hook Format in install.sh

- [x] 2.1 Update PreToolUse hook format: use `"Bash"` as matcher string
- [x] 2.2 Update PermissionRequest hook format: use `"Bash"` as matcher string
- [x] 2.3 Update TaskCompleted hook format: remove matcher field
- [x] 2.4 Add Stop hook registration in install.sh
- [x] 2.5 Add TeammateIdle hook registration in install.sh

## 3. Update uninstall.sh

- [x] 3.1 Add Stop hook removal in jq filter
- [x] 3.2 Add TeammateIdle hook removal in jq filter

## 4. Test and Verify

- [x] 4.1 Run uninstall.sh to clean existing hooks
- [x] 4.2 Run install.sh to install with correct format
- [x] 4.3 Verify settings.json has correct hook format
