## Context

cckit 是一个 Claude Code 扩展集合仓库，包含多个独立组件（hooks、skills）。barnhk 是其中一个 hook，提供安全防护和通知功能。

当前 OpenSpec 分布：
- `cckit/openspec/` - 根目录，包含 16 个 specs（大部分是 barnhk 相关）
- `hooks/barnhk/openspec/` - barnhk 内部，包含 4 个 specs（与根目录重复）和 1 个活跃变更

## Goals / Non-Goals

**Goals:**
- 统一 OpenSpec 管理位置到 `cckit/openspec/`
- 消除重复内容
- 保持变更历史完整性

**Non-Goals:**
- 不修改任何功能代码
- 不改变现有的 specs 内容

## Decisions

### 1. 统一到根目录而非拆分到组件

**选择**: 统一到 `cckit/openspec/`

**理由**:
- cckit 仓库的所有变更最终都影响整体，集中管理更清晰
- 当前 `cckit/openspec/specs/` 已包含大部分 barnhk 相关内容
- 便于跨组件变更的追踪

**备选方案**: 每个组件保留独立 openspec
- 放弃原因：barnhk 不单独分发，无需完全自治

### 2. 迁移策略：合并而非重建

**选择**: 直接移动文件，保留 git 历史

**理由**:
- `git mv` 可以保留文件历史
- 避免手动重建可能遗漏内容

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| 迁移后路径引用失效 | 检查并更新文档中的路径引用 |
| 重复文件覆盖丢失 | 先对比内容差异，合并后删除 |
