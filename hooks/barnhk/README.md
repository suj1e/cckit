# barnhk

Claude Code 安全防护插件。

## 平台

macOS / Linux / Windows（bash 环境，Claude Code 安装自带）。

依赖：`bash` 3.0+、`jq`、`curl`（均为系统常用工具）。

## 安装

```bash
npx @suj1e/cckit install barnhk
```

## 功能

- **危险命令拦截**: `rm -rf /`、`sudo`、`curl | bash`、`dd`、`mkfs`、`chmod 777 /`
- **安全命令自动批准**: Git、npm、pnpm、yarn、pip、gradle、mvn、cargo、Docker、文件操作
- **项目目录自动批准**: 项目目录下所有命令自动放行（危险命令除外）
- **Edit/Write 自动批准**: 项目目录内的文件编辑自动通过

## 配置

安装后编辑 `~/.claude/cckit/barnhk.env`（首次运行自动创建，更新不受影响）：

```bash
# 项目目录自动批准
AUTO_APPROVE_PROJECT_COMMANDS=true
```

## Hooks

| Hook | 触发时机 |
|------|----------|
| PreToolUse | 工具执行前 — 危险命令检测 |
| PermissionRequest | 权限请求 — 自动批准 |
| TaskCompleted | 任务完成 |
| Stop | 会话停止 |
| SessionEnd | 会话结束 |
| TeammateIdle | 队友空闲 |
