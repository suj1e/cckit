## ADDED Requirements

### Requirement: Detect operating system
The install script SHALL detect the operating system type.

#### Scenario: Detect macOS
- **WHEN** install.sh runs on macOS
- **THEN** the script SHALL detect it as Darwin/macOS

#### Scenario: Detect Linux
- **WHEN** install.sh runs on Linux
- **THEN** the script SHALL detect it as Linux

### Requirement: Provide OS-specific jq installation hint
The install script SHALL provide appropriate jq installation command based on OS.

#### Scenario: macOS jq hint
- **WHEN** jq is not installed on macOS
- **THEN** the script SHALL suggest `brew install jq`

#### Scenario: Debian/Ubuntu jq hint
- **WHEN** jq is not installed on Debian/Ubuntu
- **THEN** the script SHALL suggest `sudo apt install jq`

#### Scenario: RHEL/CentOS jq hint
- **WHEN** jq is not installed on RHEL/CentOS/Fedora
- **THEN** the script SHALL suggest `sudo yum install jq` or `sudo dnf install jq`
