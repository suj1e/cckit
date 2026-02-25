## ADDED Requirements

### Requirement: 结构化卡片格式

飞书通知 SHALL 使用飞书交互卡片格式，包含结构化的标题、内容和页脚元素。

#### Scenario: 卡片包含标题和页脚
- **WHEN** 发送任意类型通知
- **THEN** 卡片 header 包含通知标题
- **AND** 卡片 footer 包含分组名称

### Requirement: Body 内容解析

系统 SHALL 解析 body 参数中的键值对格式，并将其转换为结构化卡片字段。

#### Scenario: 解析键值对字段
- **WHEN** body 包含格式为 `Key: Value` 的行
- **THEN** 每个 Key-Value 对转换为一个 div 元素
- **AND** Key 作为标签显示
- **AND** Value 作为内容显示

#### Scenario: 无键值对时使用纯文本
- **WHEN** body 不包含 `Key: Value` 格式
- **THEN** 整个 body 作为单个 div 元素显示

### Requirement: 字段图标映射

系统 SHALL 为常见字段名称添加图标前缀以增强可读性。

#### Scenario: 命令字段显示键盘图标
- **WHEN** 字段名为 "Cmd"
- **THEN** 标签显示为 "⌨️ Cmd"

#### Scenario: 路径字段显示文件夹图标
- **WHEN** 字段名为 "Path"
- **THEN** 标签显示为 "📁 Path"

#### Scenario: 会话字段显示链接图标
- **WHEN** 字段名为 "Session"
- **THEN** 标签显示为 "🔗 Session"

#### Scenario: 原因字段显示灯泡图标
- **WHEN** 字段名为 "Reason"
- **THEN** 标签显示为 "💡 Reason"

#### Scenario: 工具字段显示扳手图标
- **WHEN** 字段名为 "Tool"
- **THEN** 标签显示为 "🔧 Tool"

#### Scenario: 未知字段使用默认图标
- **WHEN** 字段名不匹配任何已知映射
- **THEN** 标签显示为 "📌 <字段名>"

### Requirement: 颜色分组映射

系统 SHALL 根据通知分组为卡片设置对应的主题颜色。

#### Scenario: danger 分组显示红色
- **WHEN** 分组为 "claude-danger"
- **THEN** 卡片 header 使用红色主题

#### Scenario: permit 分组显示绿色
- **WHEN** 分组为 "claude-permit"
- **THEN** 卡片 header 使用绿色主题

#### Scenario: done 分组显示蓝色
- **WHEN** 分组为 "claude-done"
- **THEN** 卡片 header 使用蓝色主题

#### Scenario: stop 分组显示橙色
- **WHEN** 分组为 "claude-stop"
- **THEN** 卡片 header 使用橙色主题

#### Scenario: idle 分组显示灰色
- **WHEN** 分组为 "claude-idle"
- **THEN** 卡片 header 使用灰色主题

### Requirement: 解析失败降级

当 body 解析失败时，系统 SHALL 降级为纯文本展示以保证通知不丢失。

#### Scenario: 解析异常时显示原始内容
- **WHEN** body 内容格式异常或解析出错
- **THEN** 卡片显示原始 body 文本
- **AND** 通知正常发送不中断
