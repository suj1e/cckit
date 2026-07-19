---
name: ship
description: |
  End-to-end development workflow: proposal → design → plan → implement → verify → archive.
  Orchestrates opsx (OpenSpec) + Superpowers skills into a single command.
  Trigger: /ship <change-name>
---

# Ship — 从需求到上线

对指定变更执行完整开发流程：brainstorming → design → plan → implement → verify → archive。
依赖 opsx skills（OpenSpec 的 skill 封装）和 superpowers skills。

## 前置要求

- 项目有 `openspec/` 目录
- 可用 opsx skills（`opsx:new`、`opsx:propose`、`opsx:verify`、`opsx:archive`）

## 流程

### 步骤 1：创建 OpenSpec Change

调用 **opsx:new** skill，传入 change 名称：

```
/opsx:new <name>

### 步骤 2：分析上下文

读取项目相关文件，理解当前代码结构。重点：
- 受影响的模块
- 相关依赖
- 历史变更（`git log`、`CHANGELOG.md`）

### 步骤 3：收集需求

根据用户描述，用 `AskUserQuestion` 收集缺失信息：
- 变更范围和目标
- 约束条件（兼容性、性能、时间）
- 成功标准

不要超过 3 个问题，优先用选择题。

### 步骤 4：写 Proposal

将收集到的信息写入 `proposal.md`：

```markdown
# <name>

## Why
<为什么要做这个变更>

## What Changes
<具体要改什么>

## Capabilities

### Modified Capabilities
<影响的模块/功能>

### New Capabilities
<新增的功能>
```

完成后询问用户确认。

### 步骤 5：写 Design

用户确认 proposal 后，写 `design.md`：

```markdown
# <name> Design

## 架构
<整体设计思路>

## 组件
<各模块的职责和接口>

## 数据流
<关键流程>

## 错误处理
<边界情况>

## 测试策略
<怎么验证>
```

完成后询问用户确认。

### 步骤 6：写 Tasks

调用 **opsx:propose** skill，自动生成 `tasks.md`。如果用户需要调整，手动编辑。

### 步骤 7：生成 Implementation Plan

调用 **superpowers:writing-plans** skill，生成 implementation plan。

### 步骤 8：用户确认 Plan

将 plan 呈现给用户，等待确认。

### 步骤 9：执行

调用 **superpowers:subagent-driven-development** skill，按 plan 逐 task 执行。

每个 task 完成后：
- 自动 review（spec compliance + code quality）
- 修复问题后 re-review
- 确认通过后进入下一个 task

### 步骤 10：验证

调用 **opsx:verify** skill，检查所有 spec 是否满足。如有失败，修复后重新验证。

### 步骤 11：归档

询问用户是否归档：

- **归档** → `opsx:archive`
- **保留** → 结束流程，变更留在 `openspec/changes/` 下

---

## 示例

```
/ship barnhk-remove-notifications
→ opsx:new → 创建 change
→ 分析 barnhk 代码结构
→ 收集需求（范围、影响）
→ 写 proposal.md → 用户确认
→ 写 design.md → 用户确认
→ opsx:propose → tasks.md
→ writing-plans → plan
→ 用户确认 plan
→ subagent-driven-development 执行
→ opsx:verify
→ opsx:archive

/ship fix-login-timeout
→ 同上，brainstorming 阶段侧重根因分析
```

---

## 注意事项

- 如果变更太大（涉及多个独立子系统），在步骤 5 建议拆分成多个 change
- 每个确认点（proposal、design、plan）用户都可以要求修改，修改后重新确认
- 执行过程中如果遇到 blocker，暂停并报告给用户
