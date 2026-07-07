---
name: review-merge-sync
description: |
  Review a feature/bugfix branch, merge to target branch if approved, push, and optionally sync the corresponding worktree.
  Trigger: /review-merge-sync <source-branch> [target-branch]
  Default target branch: main
---

# Review → Merge → Sync

对指定分支执行完整的 review → merge → sync 工作流。

## 输入

- `<source-branch>`（必填）：要 review 并合并的分支名，如 `bugfix`、`optimize`
- `<target-branch>`（选填，默认 `main`）：合并到的目标分支

## 流程

### 步骤 1：Code Review

调用 **code-review** skill review `<source-branch>` 相对于 `<target-branch>` 的 diff：

```bash
git diff <target>...<source>
```

### 步骤 2：用户定夺

Review 完成后，使用 **AskUserQuestion** 询问：

> "Review 完成。是否将 `<source-branch>` 合并到 `<target-branch>` 并推送？"

选项：
- **合并并推送** — 执行步骤 3
- **不合并，稍后处理** — 结束流程

### 步骤 3：合并 & 推送

```bash
git checkout <target-branch> && git pull origin <target-branch> && git merge <source-branch> --no-edit && git push origin <target-branch>
```

如果出现 merge conflict，中止并报告冲突文件，让用户手动解决。

### 步骤 4：询问是否同步 Worktree

合并推送成功后，使用 **AskUserQuestion** 询问：

> "合并完成。是否同步 `<source-branch>` worktree 到最新 `<target-branch>`？"

选项：
- **同步 worktree** — 执行步骤 5
- **跳过** — 结束流程

### 步骤 5：同步 Worktree

找到 `<source-branch>` 对应的 worktree 并同步：

```bash
git worktree list | grep "<source-branch>"
```

如果找到 worktree 路径（取第一列）：

```bash
git -C "<worktree-path>" merge origin/<target-branch> --no-edit
```

如果没找到，告知用户该分支没有活跃的 worktree。

---

## 示例

```
/review-merge-sync bugfix
→ review bugfix relative to main
→ 用户确认 → 合并 bugfix 到 main → push → 同步 bugfix worktree

/review-merge-sync feat/x develop
→ review feat/x relative to develop
→ 用户确认 → 合并 feat/x 到 develop → push → 同步 feat/x worktree
```
