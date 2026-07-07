# review-merge-sync

Review → Merge → Sync 一键工作流

## 用法

```
/review-merge-sync <source-branch> [target-branch]
```

- `source-branch`：要 review 并合并的分支（必填）
- `target-branch`：目标分支（选填，默认 `main`）

## 流程

1. 启动 **code-review** skill review 指定分支
2. Review 完成后，用户决定是否合并
3. 合并到目标分支 → push
4. 询问是否同步对应 worktree

## 示例

```bash
# 默认合并到 main
/review-merge-sync bugfix

# 指定目标分支
/review-merge-sync feat/x develop
```
