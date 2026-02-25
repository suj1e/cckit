## ADDED Requirements

### Requirement: Claude 提问通知

当 Claude 使用 AskUserQuestion 工具提问时，系统 SHALL 发送通知到配置的通道。

#### Scenario: 收到提问时发送通知
- **WHEN** Claude 发送包含问题的通知
- **THEN** 系统发送通知到飞书/Bark/Discord
- **AND** 通知包含问题标题

### Requirement: 通知分组

提问通知 SHALL 使用独立的分组标识以便于区分。

#### Scenario: 使用 claude-question 分组
- **WHEN** 发送提问通知
- **THEN** 通知分组为 `claude-question`
- **AND** 飞书卡片使用蓝色主题
