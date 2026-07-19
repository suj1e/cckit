---
name: ship
description: |
  End-to-end development workflow: proposal → design → plan → implement → verify → archive.
  Orchestrates opsx (OpenSpec) + Superpowers skills into a single command.
  Trigger: /ship <change-name>
---

# Ship — 从需求到上线

对指定变更执行完整开发流程：brainstorming → design → plan → implement → verify → archive。
opsx skills（OpenSpec 的 skill 封装）负责需求追踪和变更管理，superpowers skills 负责设计思考和计划执行。

## 前置要求

- 项目有 `openspec/` 目录
- 可用 opsx skills（`opsx:new`、`opsx:continue`、`opsx:propose`、`opsx:verify`、`opsx:archive`）
- 可用 superpowers skills（`brainstorming`、`writing-plans`、`subagent-driven-development`）

## 流程

### 步骤 1：Brainstorming

调用 **superpowers:brainstorming** skill。

探索 2-3 种设计方案，分析 trade-offs，产出 validated design doc（`docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md`）。

**重要**：brainstorming 的产出是设计的输入，不跳过。

### 步骤 2：创建 Change

调用 **opsx:new** skill，传入 change 名称：

```
/opsx:new <name>
```

这会：
- 创建 change 目录和 scaffold
- 显示 artifact 序列（proposal → design → tasks）和第一个 artifact 模板
- 停下来等待下一步

### 步骤 3：填写 Proposal & Design

基于 brainstorming 的 validated design，用 `opsx:continue` 逐个填写 artifact：

1. proposal.md — Why / What Changes / Capabilities（直接使用 brainstorming 的结论）
2. design.md — 架构 / 组件 / 数据流 / 错误处理 / 测试策略（复用 brainstorming 的 design doc）

每个 artifact 完成后确认，再进入下一个。

### 步骤 4：生成 Tasks

调用 **opsx:propose** skill，自动生成 `tasks.md`。

### 步骤 5：生成 Implementation Plan

调用 **superpowers:writing-plans** skill，基于 `tasks.md` 生成可执行的 implementation plan。

### 步骤 6：用户确认 Plan

将 plan 呈现给用户，等待确认。

### 步骤 7：执行

调用 **superpowers:subagent-driven-development** skill，按 plan 逐 task 执行。

每个 task 完成后：
- 自动 review（spec compliance + code quality）
- 修复问题后 re-review
- 确认通过后进入下一个 task

### 步骤 8：验证

调用 **opsx:verify** skill，检查所有 spec 是否满足。如有失败，修复后重新验证。

### 步骤 9：归档

询问用户是否归档：

- **归档** → `opsx:archive`
- **保留** → 结束流程，变更留在 `openspec/changes/` 下

---

## 流程总览

```
/ship <change-name>

superpowers:brainstorming  →  设计方案 + 推荐方案
         ↓
opsx:new                  →  创建 change + artifact 模板
         ↓
opsx:continue (proposal)  →  proposal.md（复用 brainstorming 结论）
         ↓
opsx:continue (design)    →  design.md（复用 brainstorming design doc）
         ↓
opsx:propose              →  tasks.md
         ↓
superpowers:writing-plans →  implementation plan
         ↓
用户确认 plan
         ↓
superpowers:subagent-driven-development  →  执行
         ↓
opsx:verify               →  验证
         ↓
opsx:archive              →  归档
```

---

## 示例

```
/ship barnhk-remove-notifications
→ brainstorming → 探索方案：完全移除 vs 功能开关 vs 条件编译 → 推荐方案 A
→ opsx:new → 创建 change
→ proposal.md → 复用 brainstorming 结论
→ design.md → 复用 brainstorming design doc
→ opsx:propose → tasks.md
→ writing-plans → plan
→ 用户确认 plan
→ subagent-driven-development 执行
→ opsx:verify
→ opsx:archive

/ship fix-login-timeout
→ brainstorming → 侧重根因分析
→ opsx:new → 创建 change
→ proposal.md → 复用 brainstorming 结论
→ design.md → 复用 brainstorming design doc
→ opsx:propose → tasks.md
→ writing-plans → plan
→ 用户确认 plan
→ subagent-driven-development 执行
→ opsx:verify
→ opsx:archive
```

---

## 注意事项

- brainstorming 在 opsx:new 之前，产出 design 后直接喂给 opsx artifact，不重复劳动
- 如果变更太大（涉及多个独立子系统），在 brainstorming 阶段建议拆分成多个 change
- 每个确认点（design、plan）用户都可以要求修改，修改后重新确认
- 执行过程中如果遇到 blocker，暂停并报告给用户
