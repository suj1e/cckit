## Why

当前 cckit 仓库存在两个 OpenSpec 管理位置：`cckit/openspec/` 和 `hooks/barnhk/openspec/`。两者内容有重复，导致管理混乱、变更追踪困难。需要统一到一个位置以提高可维护性。

## What Changes

- 将 `hooks/barnhk/openspec/changes/` 下的活跃变更迁移到 `cckit/openspec/changes/`
- 将 `hooks/barnhk/openspec/specs/` 下独有的 specs 迁移到 `cckit/openspec/specs/`
- 删除 `hooks/barnhk/openspec/` 目录
- 更新 barnhk 的文档，说明 OpenSpec 统一在仓库根目录管理

## Capabilities

### New Capabilities

无。这是一个组织结构调整，不引入新功能。

### Modified Capabilities

无。现有功能行为不变，只是 OpenSpec 管理位置变化。

## Impact

- **目录结构**: 删除 `hooks/barnhk/openspec/`，`cckit/openspec/` 成为唯一管理位置
- **文档**: 更新 `CLAUDE.md` 说明 OpenSpec 统一管理策略
- **工作流**: 后续所有 barnhk 相关的变更都在 `cckit/openspec/changes/` 下创建
