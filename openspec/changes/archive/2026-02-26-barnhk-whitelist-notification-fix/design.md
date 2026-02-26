## Context

barnhk hook 目前提供两个核心功能：
1. **命令自动审批**：通过 `is_safe_command()` 函数判断命令是否在白名单中
2. **通知系统**：通过 `send_notification()` 函数发送多渠道通知

当前问题：
- `is_safe_command()` 不包含 openspec 命令
- 部分 hook 调用 `send_notification()` 时没有传递 `project_name` 参数

## Goals / Non-Goals

**Goals:**
- 让 openspec 工作流命令自动通过审批
- 统一所有通知类型的标题格式，都带项目名前缀

**Non-Goals:**
- 不修改其他白名单命令
- 不修改通知发送渠道或格式
- 不修改配置文件结构

## Decisions

### Decision 1: openspec 命令匹配模式

**选择**: 使用正则匹配 `^openspec[[:space:]]+(list|propose|apply|archive|explore|status|init)`

**理由**:
- 精确匹配已知子命令，避免意外批准未知命令
- 使用 `^` 锚定开头，防止 `echo openspec list` 这类命令被误匹配
- 使用 `[[:space:]]+` 匹配空格，跨平台兼容

**备选方案**:
- `^openspec` 简单匹配 - 拒绝，过于宽松
- 逐一列出所有子命令 - 拒绝，代码冗余

### Decision 2: 项目名获取 fallback 机制

**选择**: 优先从 JSON `cwd` 字段提取，若不存在则 fallback 到 `$PWD` 环境变量

**理由**:
- Claude Code 实际运行时大部分 hook 都有 `cwd` 字段（虽然规范文档未完整记录）
- `$PWD` 作为 fallback 确保即使没有 `cwd` 也能获取项目名
- 使用 `basename` 从路径提取最后一部分作为项目名

**备选方案**:
- 只使用 `cwd` - 拒绝，部分 hook 可能没有这个字段
- 只使用 `$PWD` - 拒绝，`cwd` 更准确（反映会话启动时的工作目录）

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| openspec 未来添加新子命令需要更新白名单 | 新子命令出现时更新 `is_safe_command()` |
| `$PWD` 可能与会话实际工作目录不一致 | `cwd` 优先，`$PWD` 只是 fallback |
