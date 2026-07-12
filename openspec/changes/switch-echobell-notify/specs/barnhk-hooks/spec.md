## MODIFIED Requirements

### Requirement: barnhk is bash-only
The barnhk plugin SHALL contain only bash (`.sh`) scripts. The configuration file SHALL use `.env` format (`barnhk.env`) with `KEY=VALUE` syntax.

#### Scenario: Plugin installation on any platform
- **WHEN** barnhk is installed on any OS
- **THEN** only `.sh` hook scripts exist for execution
- **AND** the configuration uses standard `.env` format

## ADDED Requirements

### Requirement: EchoBell webhook notification
The notification module SHALL send notifications via EchoBell webhook. The `send_notification` function SHALL POST JSON to `https://hook.echobell.one/t/{token}` with `title`, `body`, and `group` as custom variables.

#### Scenario: Notification dispatch
- **WHEN** `send_notification` is called with group, title, body, and project_name
- **THEN** the function POSTs a JSON payload to the EchoBell webhook URL
- **AND** the project name is prepended to the title

#### Scenario: Token not configured
- **WHEN** `ECHOBELL_TOKEN` is empty
- **THEN** the function silently returns without making a request

## REMOVED Requirements

### Requirement: (implicit) Bark notification support
**Reason**: Replaced by EchoBell webhook. All iOS push notifications go through EchoBell instead of Bark.

### Requirement: (implicit) Discord notification support
**Reason**: Replaced by EchoBell webhook.

### Requirement: (implicit) Feishu notification support
**Reason**: Replaced by EchoBell webhook.
