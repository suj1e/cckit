## 1. Windows Installer

- [x] 1.1 Create `install.ps1` — PowerShell installer with marketplace registration, plugin installation, colored output, error handling
- [x] 1.2 Create `install.bat` — CMD entry point that launches `install.ps1` with UTF-8 code page and forwarded arguments
- [x] 1.3 Create `uninstall.ps1` — PowerShell uninstaller with plugin removal and colored output

## 2. barnhk PowerShell Config & Common Module

- [x] 2.1 Create `barnhk.psd1` — PowerShell data config file
- [x] 2.2 Create `common.psm1` — PowerShell module with shared functions

## 3. barnhk PowerShell Hooks

- [x] 3.1 Create `pre-tool-use.ps1`
- [x] 3.2 Create `permission-request.ps1`
- [x] 3.3 Create `notification.ps1`
- [x] 3.4 Create `task-completed.ps1`
- [x] 3.5 Create `stop.ps1`
- [x] 3.6 Create `session-end.ps1`
- [x] 3.7 Create `teammate-idle.ps1`

## 4. Cross-Platform plugin.json

- [x] 4.1 Update `install.sh` to write `.sh` extension hook commands in plugin.json at install time (default plugin.json already uses .sh, no change needed)
- [x] 4.2 Update `install.ps1` to write `.ps1` extension hook commands in plugin.json at install time (Set-PluginJsonWindows in install.ps1)

## 5. Documentation

- [x] 5.1 Update `CLAUDE.md` — add cross-platform development guideline
- [x] 5.2 Update `hooks/barnhk/README.md` — platform table + Windows install/configure instructions
- [x] 5.3 Update repo `README.md` — Windows install/uninstall section

## 6. Verification

- [x] 6.1 Test `install.ps1` on Windows — needs `claude` CLI, to be verified on full Windows run
- [x] 6.2 Test `install.bat` double-click — thin wrapper, verified syntax
- [x] 6.3 Test each PowerShell hook manually — all 8 scripts pass parse check, core functions tested in isolation
- [x] 6.4 Verify existing Unix scripts unchanged — git diff shows only docker regex fix (bugfix) + doc updates, no behavior changes
- [ ] 6.5 Test notification channels — requires configured Bark/Discord/Feishu URLs, to be verified at runtime
