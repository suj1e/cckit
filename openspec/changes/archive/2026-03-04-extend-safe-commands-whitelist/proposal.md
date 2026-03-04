# Extend Safe Commands Whitelist

## Why

当前 barnhk 的安全命令白名单存在以下问题：

1. **openspec 命令不完整** - 白名单只包含部分 openspec 子命令，导致 `openspec instructions`、`openspec update`、`openspec validate` 等常用命令需要手动确认
2. **mkdir 需要手动确认** - 创建目录是常见的安全操作，不应该触发审批流程
3. **文件编辑操作需要确认** - 常见的文件操作如 `touch`、`cp`、`mv` 等应该自动批准
4. **git push 前需要手动更新文档** - 每次 push 之前都要手动更新 README.md 和 CLAUDE.md，容易遗忘

## What Changes

1. **扩展 `is_safe_command()` 函数的白名单**
   - openspec 所有子命令
   - 目录操作: `mkdir`
   - 文件操作: `touch`, `cp`, `mv`
   - Docker 常用命令

2. **添加 git push 前自动更新文档功能**
   - 检测 `git push` 命令
   - 如果存在 README.md 或 CLAUDE.md，自动更新后再 push

## Capabilities

### New Capabilities

(none - this is a configuration and workflow enhancement)

### Modified Capabilities

(none - this is a code change)

## Impact

**hooks/barnhk/lib/common.sh**:
- 修改 `is_safe_command()` 函数，扩展白名单

**hooks/barnhk/lib/pre-tool-use.sh** (新增逻辑):
- 检测 git push 命令
- 自动更新 README.md 和 CLAUDE.md

**风险评估**:
| 命令 | 风险 | 说明 |
|------|------|------|
| `mkdir` | 安全 | 只是创建空目录 |
| `touch` | 安全 | 创建空文件或更新时间戳 |
| `cp` | 安全 | 复制文件 |
| `mv` | 安全 | 移动/重命名文件 |
| `openspec *` | 安全 | OpenSpec 是项目管理工作流工具 |
| `docker ps/ls/images/logs` | 安全 | 只读操作 |
| `git push` (自动更新文档) | 低风险 | 只是更新时间戳，不修改内容 |
