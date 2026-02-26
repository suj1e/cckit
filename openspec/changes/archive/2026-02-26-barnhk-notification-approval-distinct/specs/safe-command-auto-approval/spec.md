## ADDED Requirements

### Requirement: Distinct notifications for auto-approved vs manual approval

The system SHALL send different notification types for auto-approved commands and commands requiring manual approval, distinguished by group, title, and color.

#### Scenario: Auto-approved notification uses green color
- **WHEN** a command is auto-approved by the whitelist
- **THEN** the notification SHALL use group `claude-auto-permit`
- **AND** the notification title SHALL be "🔔 Claude Permit"
- **AND** Discord color SHALL be green (5763719)
- **AND** Feishu color SHALL be green

#### Scenario: Manual approval notification uses yellow/orange color
- **WHEN** a command requires manual approval (not in whitelist)
- **THEN** the notification SHALL use group `claude-manual-permit`
- **AND** the notification title SHALL be "🔐 Claude Approval"
- **AND** Discord color SHALL be yellow/orange
- **AND** Feishu color SHALL be yellow/orange

#### Scenario: Both notification types include project name
- **WHEN** any permission notification is sent
- **THEN** the notification title SHALL include project name prefix `[项目名]`
