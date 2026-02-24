## ADDED Requirements

### Requirement: Detect critical dangerous commands
The system SHALL detect and block shell commands that could cause irreversible system damage.

#### Scenario: Block rm -rf root
- **WHEN** a command matches pattern `rm -rf /` or `rm -rf /*`
- **THEN** the hook SHALL exit with non-zero code and output error message

#### Scenario: Block disk write commands
- **WHEN** a command contains `dd` with `of=/dev/` pattern
- **THEN** the hook SHALL block execution and log the attempt

#### Scenario: Block filesystem formatting
- **WHEN** a command contains `mkfs` targeting any device
- **THEN** the hook SHALL block execution

### Requirement: Detect high-risk commands
The system SHALL detect commands that require elevated privileges or pose security risks.

#### Scenario: Detect sudo usage
- **WHEN** a command starts with `sudo`
- **THEN** the hook SHALL block and notify user

#### Scenario: Detect curl pipe to shell
- **WHEN** a command matches pattern `curl | bash` or `curl | sh` or `wget | bash`
- **THEN** the hook SHALL block execution

#### Scenario: Detect insecure permissions
- **WHEN** a command contains `chmod -R 777` or `chmod 777 /`
- **THEN** the hook SHALL block execution

### Requirement: Allow medium-risk commands
The system SHALL allow medium-risk commands without blocking or warning.

#### Scenario: Allow netcat listener
- **WHEN** a command contains `nc -l` or `netcat -l`
- **THEN** the hook SHALL allow execution

#### Scenario: Allow kill all processes
- **WHEN** a command contains `kill -9 -1` or `pkill -f`
- **THEN** the hook SHALL allow execution

