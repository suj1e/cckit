## Why

当前 barnhk hook 存在两个问题：

1. **白名单不完整**：openspec 命令（用于变更管理的工作流命令）不在自动审批白名单中，每次执行都需要手动确认，影响开发效率。

2. **通知标题不一致**：部分 hook 的通知标题缺少项目名前缀，导致用户无法快速识别通知来自哪个项目。

## What Changes

- 扩展 `is_safe_command()` 白名单，添加 `openspec` 命令系列（list、propose、apply、archive、explore、status、init）
- 修复 `pre-tool-use.sh`（claude-danger）、`permission-request.sh`（claude-permit）、`task-completed.sh`（claude-done）三个 hook 的通知标题缺少项目名问题
- 添加 fallback 机制：当输入 JSON 没有 `cwd` 字段时，使用 `$PWD` 环境变量获取项目名

## Capabilities

### New Capabilities

无新 capability。

### Modified Capabilities

- `safe-command-auto-approval`: 添加 openspec 命令到自动审批白名单
- `notification-project-prefix`: 扩展覆盖范围到所有通知类型，并添加 `$PWD` fallback 机制

## Impact

- **修改文件**：
  - `hooks/barnhk/lib/common.sh` - 扩展 `is_safe_command()` 函数
  - `hooks/barnhk/lib/pre-tool-use.sh` - 添加项目名提取逻辑
  - `hooks/barnhk/lib/permission-request.sh` - 添加项目名提取逻辑
  - `hooks/barnhk/lib/task-completed.sh` - 添加项目名提取逻辑
- **影响功能**：命令自动审批、通知显示
- **向后兼容**：完全兼容，无 breaking changes
