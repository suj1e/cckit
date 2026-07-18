# barnhk 通知功能移除 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 从 barnhk 中完全移除通知功能（Bark/Discord/飞书后端 + 所有 hook 中的通知调用），保留安全防护核心功能

**Architecture:** 删除 `common.sh` 中的通知后端函数和 `send_notification` 分发器，删除 `notification.sh` 文件，从 6 个 hook 脚本中移除 `send_notification` 调用，清理配置文件和 README 中的通知相关配置和文档。

**Tech Stack:** bash

## Global Constraints

- 纯 bash，跨平台（macOS/Linux/Windows Git Bash）
- 依赖：bash 3.0+、jq、curl
- 退出码：阻断用 `exit 2`，非阻断用 `exit 0`
- 删除代码后需验证 `bash -n` 语法正确
- `get_icon()` 函数（第 36-43 行）如果不再被任何 hook 使用，也应一并删除

---

### Task 1: 从 common.sh 删除通知后端函数

**Files:**
- Modify: `hooks/barnhk/lib/common.sh`

**Interfaces:**
- Removes: `get_icon()`, `send_bark_notification()`, `get_discord_color()`, `send_discord_notification()`, `get_feishu_color()`, `get_field_icon()`, `parse_body_fields()`, `send_feishu_notification()`, `send_notification()`
- Also removes: `get_notification_mode()`, `get_notification_title()`, `extract_transcript_content()` (notification helper functions)
- Keeps: `load_config()`, `json_value()`, `truncate_string()`, `is_safe_command()`, `check_danger_level()`

**删除的行范围（common.sh）：**

```
第 34-43 行: get_icon()
第 45-89 行: send_bark_notification()
第 91-121 行: get_discord_color()
第 123-165 行: send_discord_notification()
第 167-197 行: get_feishu_color()
第 199-211 行: get_field_icon()
第 213-257 行: parse_body_fields()
第 259-337 行: send_feishu_notification()
第 339-360 行: send_notification()
第 498-517 行: get_notification_mode()
第 519-535 行: get_notification_title()
第 537-644 行: extract_transcript_content()
```

删除后，`common.sh` 剩余内容为：
- `load_config()` (第 9-13 行)
- `json_value()` (第 16-20 行)
- `truncate_string()` (第 23-32 行)
- `is_safe_command()` (第 ~362-441 行)
- `check_danger_level()` (第 ~444-496 行)

- [ ] **Step 1: 删除通知相关函数**

删除 `common.sh` 中以下所有函数（第 34-360 行和第 498-644 行）：

```bash
# 删除以下完整函数块：

# 第 34-43 行
get_icon() {
    case "$1" in
        permission_prompt) echo "🔐" ;;
        question) echo "❓" ;;
        idle_prompt) echo "⏳" ;;
        *) echo "🔔" ;;
    esac
}

# 第 45-89 行
send_bark_notification() { ... }

# 第 91-121 行
get_discord_color() { ... }

# 第 123-165 行
send_discord_notification() { ... }

# 第 167-197 行
get_feishu_color() { ... }

# 第 199-211 行
get_field_icon() { ... }

# 第 213-257 行
parse_body_fields() { ... }

# 第 259-337 行
send_feishu_notification() { ... }

# 第 339-360 行
send_notification() {
    ...
    send_bark_notification "$group" "$title" "$body"
    send_discord_notification "$group" "$title" "$body"
    send_feishu_notification "$group" "$title" "$body"
}

# 第 498-517 行
get_notification_mode() { ... }

# 第 519-535 行
get_notification_title() { ... }

# 第 537-644 行
extract_transcript_content() { ... }
```

- [ ] **Step 2: 验证语法**

Run: `bash -n hooks/barnhk/lib/common.sh`
Expected: 无输出（语法正确）

- [ ] **Step 3: Commit**

```bash
git add hooks/barnhk/lib/common.sh
git commit -m "feat(barnhk): remove notification backends from common.sh"
```

---

### Task 2: 删除 notification.sh 并清理 hook 脚本中的通知调用

**Files:**
- Delete: `hooks/barnhk/lib/notification.sh`
- Modify: `hooks/barnhk/lib/pre-tool-use.sh`, `hooks/barnhk/lib/permission-request.sh`, `hooks/barnhk/lib/task-completed.sh`, `hooks/barnhk/lib/stop.sh`, `hooks/barnhk/lib/session-end.sh`, `hooks/barnhk/lib/teammate-idle.sh`

**Interfaces:**
- Deletes: `notification.sh` (entire file)
- Removes: `send_notification` call from each hook script

每个 hook 脚本中需要删除的内容：

**pre-tool-use.sh**（第 40 行和第 47 行）：
```bash
# 删除这两行：
send_notification "claude-danger" "$TITLE_DANGER" "Blocked: $COMMAND" "$PROJECT_NAME"
```

**permission-request.sh**（第 70-71 行）：
```bash
# 删除这两行：
send_notification "claude-auto-permit" "$TITLE_PERMIT" "$BODY" "$PROJECT_NAME"
```

**task-completed.sh**（第 49 行）：
```bash
# 删除这一行：
send_notification "claude-done" "$TITLE_DONE" "$BODY" "$PROJECT_NAME"
```

**stop.sh**（第 36 行）：
```bash
# 删除这一行：
send_notification "claude-stop" "$TITLE_STOP" "$BODY" "$PROJECT_NAME"
```

**session-end.sh**（第 38 行）：
```bash
# 删除这一行：
send_notification "claude-stop" "$TITLE_STOP" "$BODY" "$PROJECT_NAME"
```

**teammate-idle.sh**（第 38 行）：
```bash
# 删除这一行：
send_notification "claude-idle" "$TITLE_IDLE" "$BODY" "$PROJECT_NAME"
```

**notification.sh** — 整个文件删除（已无任何 hook 调用它）

- [ ] **Step 1: 删除 notification.sh**

```bash
rm hooks/barnhk/lib/notification.sh
```

- [ ] **Step 2: 从 pre-tool-use.sh 删除 send_notification 调用**

删除第 40 行和第 47 行（危险命令拦截时的通知发送）。

- [ ] **Step 3: 从 permission-request.sh 删除 send_notification 调用**

删除第 70-71 行（自动批准时的通知发送）。

- [ ] **Step 4: 从 task-completed.sh 删除 send_notification 调用**

删除第 49 行。

- [ ] **Step 5: 从 stop.sh 删除 send_notification 调用**

删除第 36 行。

- [ ] **Step 6: 从 session-end.sh 删除 send_notification 调用**

删除第 38 行。

- [ ] **Step 7: 从 teammate-idle.sh 删除 send_notification 调用**

删除第 38 行。

- [ ] **Step 8: 验证所有脚本语法**

```bash
for f in hooks/barnhk/lib/*.sh; do bash -n "$f" || echo "FAIL: $f"; done
echo "Done"
```
Expected: 只输出 `Done`（全部通过）

- [ ] **Step 9: Commit**

```bash
git add -A
git commit -m "feat(barnhk): remove notification.sh and send_notification calls from hooks"
```

---

### Task 3: 清理配置文件和 README

**Files:**
- Modify: `hooks/barnhk/lib/barnhk.conf`
- Modify: `hooks/barnhk/README.md`

**Interfaces:**
- Produces: 无通知相关配置的 `barnhk.conf`
- Produces: 无通知相关内容的 `README.md`

**barnhk.conf** 删除以下变量：

```bash
# === Bark (iOS Push Notifications) ===
BARK_SERVER_URL=""

# === Discord Webhook ===
DISCORD_WEBHOOK_URL=""
DISCORD_COLOR_DANGER="15548997"
DISCORD_COLOR_PERMIT="5763719"
DISCORD_COLOR_DONE="3066993"
DISCORD_COLOR_STOP="15105570"
DISCORD_COLOR_IDLE="8421504"

# === Feishu Webhook ===
FEISHU_WEBHOOK_URL=""

# === Notification Titles ===
TITLE_DANGER="⚠️ Claude Danger"
TITLE_PERMIT="🔔 Claude Permit"
TITLE_APPROVAL="🔐 Claude Approval"
TITLE_DONE="✅ Claude Done"
TITLE_STOP="🛑 Claude Stop"
TITLE_IDLE="💤 Teammate Idle"
TITLE_QUESTION="❓ Claude Question"
TITLE_IDLE_PROMPT="⏳ Claude Waiting"

# === Notification Type Handling ===
NOTIFICATION_PERMISSION_PROMPT="skip"
NOTIFICATION_QUESTION="transcript"
NOTIFICATION_IDLE_PROMPT="transcript"
```

保留：`SAFE_COMMANDS`、`AUTO_APPROVE_PROJECT_COMMANDS`、`DEBUG_ENABLED`

**README.md** 删除以下内容：
- "## 功能" 中的通知相关 bullet（EchoBell 通知行）
- "## 代码结构" 整个 section（已引用不存在的文件）
- "## Hooks" table 中的 Notification 行

- [ ] **Step 1: 更新 barnhk.conf**

删除所有通知相关配置变量，保留安全相关配置。

- [ ] **Step 2: 更新 README.md**

删除通知功能描述、过时的代码结构图、Notification hook 行。

- [ ] **Step 3: 验证**

Run: `bash -c 'source hooks/barnhk/lib/barnhk.conf && echo OK'`
Expected: 输出 `OK`

- [ ] **Step 4: Commit**

```bash
git add hooks/barnhk/lib/barnhk.conf hooks/barnhk/README.md
git commit -m "feat(barnhk): remove notification config and docs"
```

---

## Self-Review

**Spec coverage:**
- ✅ 所有通知后端函数删除 → Task 1
- ✅ notification.sh 删除 + hook 脚本清理 → Task 2
- ✅ 配置和文档清理 → Task 3

**Placeholder scan:** 无 TBD/TODO，所有代码完整。

**Consistency:** `send_notification` 完全清除，无残留调用。
