# barnhk 通知重构 + 配置路径修复

> **状态**: approved
> **日期**: 2026-07-17
> **范围**: hooks/barnhk — 通知后端精简 + 用户配置路径

---

## Why

当前 barnhk 维护 3 个通知后端（Bark + Discord + 飞书），代码量大（`common.sh` 中通知相关约 350 行）、配置繁琐（3 个 URL + 5 个 Discord 颜色 + 飞书卡片解析逻辑）。同时 `barnhk.conf` 放在插件缓存目录内，用户无法直接编辑，配置覆盖风险高。

目标：通知后端精简为 EchoBell + 钉钉两个，配置路径改为 `~/.claude/cckit/barnhk.env`。

---

## 变更

### 1. 通知后端：Bark/Discord/飞书 → EchoBell + 钉钉

| 后端 | 配置变量 | 实现 |
|------|---------|------|
| **EchoBell** | `ECHOBELL_TOKEN` | POST JSON 到 `https://hook.echobell.one/t/{token}`，传 `title`、`body`、`group` |
| **钉钉** | `DINGTALK_WEBHOOK_URL` | POST JSON 到 webhook URL，Markdown 格式 |

两个后端独立开关，都配了就同时发。

### 2. 配置路径：插件缓存 → 用户主目录

加载优先级：

```
~/.claude/cckit/barnhk.env    ← 用户配置（优先，不存在则回退）
        ↓
${CLAUDE_PLUGIN_ROOT}/lib/barnhk.conf  ← 插件默认配置（模板）
```

`barnhk.conf` 随插件发布作为默认模板，用户可复制到 `~/.claude/cckit/barnhk.env` 进行个性化配置。

### 3. 配置变量（`barnhk.conf` / `barnhk.env`）

```bash
# 通知后端
ECHOBELL_TOKEN=""                          # EchoBell webhook token
DINGTALK_WEBHOOK_URL=""                    # 钉钉自定义机器人 webhook

# 安全命令白名单（空格分隔的 regex 模式）
SAFE_COMMANDS=""

# 项目目录自动批准
AUTO_APPROVE_PROJECT_COMMANDS=true

# 通知标题
TITLE_DANGER="⚠️ Claude Danger"
TITLE_PERMIT="🔔 Claude Permit"
TITLE_APPROVAL="🔐 Claude Approval"
TITLE_DONE="✅ Claude Done"
TITLE_STOP="🛑 Claude Stop"
TITLE_IDLE="💤 Teammate Idle"
TITLE_QUESTION="❓ Claude Question"

# 通知类型处理
NOTIFICATION_PERMISSION_PROMPT="skip"
NOTIFICATION_QUESTION="transcript"
NOTIFICATION_IDLE_PROMPT="transcript"

# 调试
DEBUG_ENABLED=false
```

---

## 影响文件

| 文件 | 变更 |
|------|------|
| `hooks/barnhk/lib/common.sh` | 删除 Bark/Discord/飞书相关函数（~350 行），新增 `send_echobell_notification`、`send_dingtalk_notification`（~60 行），修改 `load_config` 优先级逻辑 |
| `hooks/barnhk/lib/barnhk.conf` | 删除旧 URL/颜色字段，更新为 EchoBell + 钉钉配置变量 |
| `hooks/barnhk/lib/notification.sh` | 无需改动（调用 `send_notification`，分发逻辑在 common.sh） |
| `hooks/barnhk/README.md` | 更新配置说明路径和变量名 |

---

## 影响范围

- **Breaking**: 使用 Bark/Discord/飞书通知的用户需要迁移到 EchoBell 或钉钉
- **非 Breaking**: 仅使用安全防护功能的用户无感知
