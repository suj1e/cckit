# Design: Add Upd Skill

## Goals

- 提供一个简单的 `/upd` 命令来更新项目文档
- 自动检测代码变更并更新对应的文档内容
- 支持配置扩展模式（更新所有 .md 文件）
- 自动提交并推送文档更新

## Non-Goals

- 不支持复杂的文档生成（如 API 文档自动生成）
- 不支持自定义文档模板
- 不支持多语言文档

## Decisions

### Decision 1: Skill 作为独立插件

**Rationale:** `/upd` 是一个通用技能，应该作为独立插件安装，而不是 cckit 的内置功能。

**结构:**
```
skills/
└── upd/
    ├── SKILL.md           # 技能定义
    └── .claude-plugin/
        └── plugin.json     # 插件元数据
```

### Decision 2: 默认只更新 README.md 和 CLAUDE.md

**Rationale:** 大多数项目只需要更新这两个核心文档。更新所有 .md 文件可能会导致意外修改。

**配置:**
- `UPD_TARGET_ALL_MD=false` (默认) - 只更新 README.md 和 CLAUDE.md
- `UPD_TARGET_ALL_MD=true` - 更新项目中的所有 .md 文件

### Decision 3: 自动提交和推送

**Rationale:** 简化工作流，用户不需要手动执行 git 操作。

**提交信息格式:**
```
docs: update documentation
```

**行为:**
1. 检查是否有文档变更
2. 如果有变更，执行 `git add` + `git commit` + `git push`
3. 如果没有变更，提示 "No documentation updates needed"

### Decision 4: 变更检测策略

**Rationale:** 通过分析最近的 git 提交来理解代码变更。

**检测方式:**
1. `git status` - 查看当前状态
2. `git log -5 --oneline` - 查看最近提交
3. `git diff HEAD~1 --stat` - 查看最近变更的文件

## Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│                        /upd Workflow                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. Detect Changes                                              │
│     ├── git status                                              │
│     ├── git log -5 --oneline                                    │
│     └── git diff HEAD~1 --stat                                  │
│                                                                 │
│  2. Identify Target Docs                                        │
│     ├── Check UPD_TARGET_ALL_MD config                          │
│     ├── Default: README.md, CLAUDE.md (if exist)               │
│     └── Extended: all .md files (exclude node_modules, .git)   │
│                                                                 │
│  3. Analyze & Update                                             │
│     ├── Read current doc content                                │
│     ├── Identify outdated sections                              │
│     └── Update with accurate information                        │
│                                                                 │
│  4. Commit & Push                                                │
│     ├── git add <docs>                                          │
│     ├── git commit -m "docs: update documentation"              │
│     └── git push                                                │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Risks / Trade-offs

| 风险 | 缓解措施 |
|------|----------|
| 可能更新不准确的文档内容 | Claude 应基于实际代码变更进行更新，不猜测 |
| 更新所有 .md 可能修改不相关文件 | 默认关闭，用户需显式启用 |
| 推送失败 | 显示错误信息，保留本地提交 |
| 没有检测到变更 | 提示用户，不执行提交 |
