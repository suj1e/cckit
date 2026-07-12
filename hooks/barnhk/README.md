# barnhk

Claude Code 安全防护 + 多通道通知插件。

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
- **多通道通知**: Bark (iOS) + Discord + 飞书
- **项目目录自动批准**: 项目目录下所有命令自动放行（危险命令除外）
- **Edit/Write 自动批准**: 项目目录内的文件编辑自动通过

## 配置

安装后编辑 `~/.claude/plugins/cache/cckit/barnhk/<version>/lib/barnhk.conf`：

```bash
# 通知通道
BARK_SERVER_URL="https://api.day.app/YOUR_KEY"
DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/..."
FEISHU_WEBHOOK_URL="https://open.feishu.cn/open-apis/bot/v2/hook/..."

# 通知类型处理 (skip / default / transcript)
NOTIFICATION_PERMISSION_PROMPT="skip"
NOTIFICATION_QUESTION="transcript"
NOTIFICATION_IDLE_PROMPT="transcript"

# 项目目录自动批准
AUTO_APPROVE_PROJECT_COMMANDS=true
```

## Hooks

| Hook | 触发时机 |
|------|----------|
| PreToolUse | 工具执行前 — 危险命令检测 |
| PermissionRequest | 权限请求 — 自动批准 |
| Notification | Claude 通知 — 提问/提醒 |
| TaskCompleted | 任务完成 |
| Stop | 会话停止 |
| SessionEnd | 会话结束 |
| TeammateIdle | 队友空闲 |

## 代码结构

```
lib/
├── common.sh         # 入口 + dispatch_hook + 工具函数
├── hooks.sh          # 7 个 hook 逻辑函数
├── notify.sh         # Bark + Discord + 飞书通知后端
├── safety.sh         # 命令安全检查
├── transcript.sh     # 会话内容提取
├── barnhk.conf       # 配置文件
├── *.sh              # 7 个入口脚本（5 行 dispatch）
└── tests/
    ├── test-safety.sh
    ├── test-notify.sh
    └── test-hooks.sh
```
