## MODIFIED Requirements

### Requirement: plugin.json hook commands support cross-platform execution
All hook `command` fields in `plugin.json` SHALL use the platform-appropriate script extension. On Unix the commands SHALL reference `.sh` scripts; on Windows the commands SHALL reference `.ps1` scripts. The installer SHALL write the correct path during installation.

#### Scenario: Unix installation writes .sh commands
- **WHEN** `install.sh` runs on macOS or Linux
- **THEN** plugin.json hook commands use `"${CLAUDE_PLUGIN_ROOT}"/lib/xxx.sh` format

#### Scenario: Windows installation writes .ps1 commands
- **WHEN** `install.ps1` runs on Windows
- **THEN** plugin.json hook commands use `"${CLAUDE_PLUGIN_ROOT}"/lib/xxx.ps1` format

#### Scenario: Path quoting for spaces
- **WHEN** `${CLAUDE_PLUGIN_ROOT}` contains spaces
- **THEN** the command string uses the quoted format `"${CLAUDE_PLUGIN_ROOT}"/lib/xxx.ps1` (or `.sh`) to handle spaces
