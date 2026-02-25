## Why

当前飞书通知的内容格式过于简单，仅显示纯文本标题和内容，缺乏视觉层次和结构化信息展示。用户反馈希望通知内容更"好看和清晰"，需要优化飞书卡片消息的呈现方式。

## What Changes

- 使用飞书富文本卡片元素替代纯文本展示
- 为不同通知类型设计结构化的字段布局
- 添加图标/分隔线增强视觉层次
- 优化命令/路径/会话信息的展示格式
- 统一各类通知的视觉风格

## Capabilities

### New Capabilities

- `feishu-card-format`: 飞书通知卡片格式化能力，定义各类通知的结构化展示方式

### Modified Capabilities

无 - 这是新增功能，不改变现有行为规范

## Impact

- `hooks/barnhk/lib/common.sh` - 修改 `send_feishu_notification()` 函数，支持结构化卡片格式
- 所有 hook 脚本可能需要调整 `send_notification()` 调用方式以传递更丰富的结构化数据
