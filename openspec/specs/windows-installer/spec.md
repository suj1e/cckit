# windows-installer

Windows installation and uninstallation scripts for cckit plugins.

## Requirements

### Requirement: install.ps1 installs cckit plugins via marketplace
The PowerShell installer SHALL add the cckit marketplace and install specified plugins using Claude Code CLI. SHALL support both "install all" (no arguments) and "install specific plugin" (plugin name argument) modes. Valid plugin names are `jbrick` and `barnhk`.

#### Scenario: Install all plugins
- **WHEN** user runs `./install.ps1` with no arguments
- **THEN** marketplace is registered (if not already), and both `jbrick@cckit` and `barnhk@cckit` are installed via `claude plugin install`

#### Scenario: Install specific plugin
- **WHEN** user runs `./install.ps1 barnhk` with a valid plugin name
- **THEN** only `barnhk@cckit` is installed

#### Scenario: Unknown plugin name
- **WHEN** user runs `./install.ps1 unknown-plugin`
- **THEN** installer displays error with available plugin list and exits with code 1

### Requirement: install.bat provides CMD entry point
The batch file SHALL act as a thin wrapper that invokes `install.ps1` with all arguments forwarded. SHALL set UTF-8 code page (`chcp 65001`) before invocation for correct character rendering.

#### Scenario: Double-click install
- **WHEN** user double-clicks `install.bat` in Windows Explorer with no arguments
- **THEN** PowerShell executes `install.ps1` and installs all plugins

#### Scenario: CMD with arguments
- **WHEN** user runs `install.bat barnhk` from CMD
- **THEN** `install.ps1 barnhk` is invoked via PowerShell

### Requirement: uninstall.ps1 uninstalls cckit plugins
The PowerShell uninstaller SHALL remove specified plugins via `claude plugin uninstall`. SHALL support "uninstall all" and "uninstall specific plugin" modes.

#### Scenario: Uninstall specific plugin
- **WHEN** user runs `./uninstall.ps1 barnhk`
- **THEN** `barnhk@cckit` is uninstalled via `claude plugin uninstall`

#### Scenario: Uninstall all plugins
- **WHEN** user runs `./uninstall.ps1` with no arguments
- **THEN** both `jbrick@cckit` and `barnhk@cckit` are uninstalled

### Requirement: Installer adapts hook script extensions per platform
The PowerShell installer SHALL post-process each installed plugin's `plugin.json` to convert canonical `.sh` script paths to `.ps1` for Windows compatibility. The Unix installer SHALL similarly normalize any stale `.ps1` paths to `.sh`. This adaptation SHALL apply to all plugins generically (not hardcoded per plugin name), so future plugins with hook commands require no installer changes.

#### Scenario: Windows adapts .sh to .ps1 for all plugins
- **WHEN** `install.ps1` installs any plugin whose `plugin.json` contains `.sh` hook commands
- **THEN** the installed cache copy has all `.sh` replaced with `.ps1`

#### Scenario: Unix adapts .ps1 to .sh for all plugins
- **WHEN** `install.sh` installs any plugin whose `plugin.json` contains `.ps1` hook commands (e.g., stale cache from prior Windows install)
- **THEN** the installed cache copy has all `.ps1` replaced with `.sh`

#### Scenario: Plugins without hooks are unaffected
- **WHEN** `install.sh` or `install.ps1` installs a plugin with no `hooks` section (e.g., `jbrick`, `just-task`)
- **THEN** the adaptation step finds no `.sh`/`.ps1` references and silently succeeds

### Requirement: Installer uses colored console output
The installer SHALL display colored output (green for success, cyan for progress, red for errors) using PowerShell's `Write-Host` with `-ForegroundColor`.

#### Scenario: Successful installation output
- **WHEN** a plugin installs successfully
- **THEN** a green checkmark with plugin name is displayed

#### Scenario: Failed installation output
- **WHEN** a plugin fails to install
- **THEN** a red cross with error details is displayed
