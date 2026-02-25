## Context

barnhk 是一个全局安装的 hook，配置文件位于 `~/.claude/hooks/barnhk/lib/barnhk.conf`。当前设计为了保护用户配置，只在配置文件不存在时才复制。

## Goals / Non-Goals

**Goals:**
- 确保用户始终使用最新的配置模板
- 简化安装逻辑

**Non-Goals:**
- 不提供配置迁移或合并功能
- 不备份旧配置

## Decisions

### 直接覆盖而非合并

**选择**: 直接覆盖

**理由**:
- 合并逻辑复杂，容易出错
- 配置项不多，用户重新配置成本低
- 用户选择了这个方案

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| 用户丢失自定义配置 | 在输出中提示用户检查配置 |
