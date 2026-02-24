## ADDED Requirements

### Requirement: Install script runs successfully on Linux

The install script SHALL execute without errors on Linux systems with bash and jq installed.

#### Scenario: Fresh installation on Ubuntu/Debian
- **WHEN** user runs `./install.sh` on Ubuntu or Debian
- **THEN** script completes successfully with all hooks registered in settings.json

#### Scenario: Fresh installation on Fedora/RHEL
- **WHEN** user runs `./install.sh` on Fedora or RHEL-based distribution
- **THEN** script completes successfully with all hooks registered in settings.json

### Requirement: Install script provides clear error messages

The install script SHALL provide actionable error messages when requirements are not met.

#### Scenario: Missing jq dependency
- **WHEN** jq is not installed on the system
- **THEN** script displays installation instructions specific to the detected OS

#### Scenario: Bash version incompatibility
- **WHEN** bash version is older than 4.0
- **THEN** script displays a warning about potential compatibility issues

### Requirement: Hook scripts work correctly on Linux

All hook scripts SHALL function identically on Linux and macOS.

#### Scenario: PreToolUse hook blocks dangerous commands on Linux
- **WHEN** a dangerous command like `rm -rf /` is detected on Linux
- **THEN** hook blocks the command and sends notification (if configured)

#### Scenario: PermissionRequest hook auto-approves safe commands on Linux
- **WHEN** a whitelisted command like `git status` is executed on Linux
- **THEN** hook auto-approves the command without user interaction

### Requirement: Path resolution works on Linux

All path operations in scripts SHALL resolve correctly on Linux filesystems.

#### Scenario: Script directory resolution
- **WHEN** any hook script needs to find its installation directory
- **THEN** path is correctly resolved regardless of how the script is invoked
