## Context

当前 `notify.sh` 包含 3 个通知后端（Bark + Discord + 飞书），共 ~350 行。每个后端都有独立的颜色映射、JSON 构造、curl 调用。配置 `barnhk.conf` 使用 bash 变量语法。

## Goals / Non-Goals

**Goals:**
- 通知后端统一为 EchoBell webhook
- 配置格式改为 `.env` 标准格式
- 减少 `notify.sh` 代码量（350 → ~15 行）
- 保持 `send_notification` 接口不变

**Non-Goals:**
- 不改动 hook 逻辑（hooks.sh）
- 不改动安全检查（safety.sh）
- 不改动 transcript 提取（transcript.sh）

## Decisions

### 1. EchoBell webhook 频道模式

POST JSON 到 `https://hook.echobell.one/t/{token}`，传 `title`、`body`、`group` 三个自定义变量。用户端用模板 `{{title}} - {{body}}` 定义通知样式。

### 2. .env 配置格式

从 `barnhk.conf`（bash source）改为 `barnhk.env`（`.env` 标准格式）。内容：
```bash
ECHOBELL_TOKEN=t29r2oi0978ektw6lsdx
AUTO_APPROVE_PROJECT_COMMANDS=true
TITLE_DANGER=⚠️ Claude Danger
...
```

### 3. 废弃字段

删除：`BARK_SERVER_URL`、`DISCORD_WEBHOOK_URL`、`FEISHU_WEBHOOK_URL`、`DISCORD_COLOR_*`（5 个）
