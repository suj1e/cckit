# ship

End-to-end development workflow: proposal → design → plan → implement → verify → archive.

## 用法

```
/ship <change-name>
```

## 流程

1. 创建 OpenSpec change
2. 分析代码库上下文
3. 收集需求
4. 写 proposal.md
5. 写 design.md
6. 写 tasks.md
7. 生成 implementation plan
8. 执行（subagent-driven）
9. 验证
10. 归档

## 示例

```bash
/ship barnhk-remove-notifications
/ship fix-login-timeout
/ship new-dashboard
```
