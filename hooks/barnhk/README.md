# barnhk

Claude Code Hooks 增强工具包，提供危险命令防护、安全命令自动审批、多通道推送通知等功能。

## 平台支持

| 平台 | 支持状态 |
|------|----------|
| macOS | ✅ 完全支持 |
| Linux | ✅ 完全支持 |
| Windows (WSL) | 🧪 应该可用 |

## 功能

| 功能 | 说明 |
|------|------|
| 🛡️ **危险命令防护** | 检测并阻断 `rm -rf /`、`sudo`、`curl \| bash` 等危险命令 |
| ✅ **安全命令自动审批** | `git`、`npm`、`pnpm`、`gradle` 等常用命令自动批准 |
| 🔔 **多通道通知** | 支持 Bark (iOS)、Discord、飞书 Webhook |

## Hooks 类型

| Hook | 触发时机 | 功能 |
|------|----------|------|
| `PreToolUse` | 执行工具之前 | 危险命令检测与阻断 |
| `PermissionRequest` | 请求权限时 | 安全命令自动审批 + 通知 |
| `Notification` | Claude 发送通知时 | 提问/权限提醒通知 |
| `TaskCompleted` | 任务完成时 | 通知 |
| `Stop` | 用户停止会话时 | 通知 |
| `SessionEnd` | 会话完全结束时 | 通知 |
| `TeammateIdle` | 队友空闲时 | 通知 |

## 安装

### 依赖

- `bash` 3.0+ - Shell 解释器
- `jq` - JSON 处理工具
- `curl` - 发送通知（可选）

安装 jq：
- **macOS**: `brew install jq`
- **Debian/Ubuntu**: `sudo apt install jq`
- **RHEL/CentOS/Fedora**: `sudo yum install jq` 或 `sudo dnf install jq`
- **Arch Linux**: `sudo pacman -S jq`
- **openSUSE**: `sudo zypper install jq`

### 调试模式

如果安装遇到问题，可以启用详细日志：

```bash
VERBOSE=true ./install.sh
```

### 安装/卸载

```bash
# 安装（复制到全局目录 ~/.claude/hooks/barnhk/）
./install.sh

# 卸载
./uninstall.sh
```

安装后文件位置：
- 脚本：`~/.claude/hooks/barnhk/lib/`
- 配置：`~/.claude/hooks/barnhk/lib/barnhk.conf`

修改配置直接编辑 `~/.claude/hooks/barnhk/lib/barnhk.conf`，不会影响项目仓库。

## 通知配置

barnhk 支持三种通知通道，可同时配置：

### Bark (iOS 推送)

```bash
# 在 barnhk.conf 中设置
BARK_SERVER_URL="https://api.day.app/YOUR_KEY"
```

### Discord Webhook

```bash
# 在 barnhk.conf 中设置
DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/123456789/abcdefg"
```

### 飞书 Webhook

```bash
# 在 barnhk.conf 中设置
FEISHU_WEBHOOK_URL="https://open.feishu.cn/open-apis/bot/v2/hook/xxxxx"
```

飞书支持结构化卡片消息格式，包含：
- 彩色标题栏（根据通知类型）
- 状态描述行
- 分隔线
- 结构化字段（带图标）

**颜色分组：**

| 分组 | 颜色 | 说明 |
|------|------|------|
| `claude-danger` | 🔴 红色 | 危险命令被阻断 |
| `claude-permit` | 🟢 绿色 | 权限审批 |
| `claude-done` | 🔵 蓝色 | 任务完成 |
| `claude-stop` | 🟠 橙色 | 会话停止 |
| `claude-idle` | ⚪ 灰色 | 队友空闲 |
| `claude-question` | 🟣 紫色 | Claude 提问/通知 |

**字段图标：**

| 字段 | 图标 | 示例 |
|------|------|------|
| Cmd | ⌨️ | ⌨️ Cmd |
| Path | 📁 | 📁 Path |
| Session | 🔗 | 🔗 Session |
| Tool | 🔧 | 🔧 Tool |
| Reason | 💡 | 💡 Reason |
| 其他 | 📌 | 📌 Field |

## 通知格式示例

### 自动批准通知（飞书卡片格式）
```
┌────────────────────────────────┐
│ 🔔 Claude Permit        (绿色) │
├────────────────────────────────┤
│ 📋 [BASH] Auto-approved        │
│ ──────────────────────────────│
│ ⌨️ Cmd                         │
│    git status                  │
│ 🔗 Session                     │
│    a1b2c3d4e5f6...             │
├────────────────────────────────┤
│ claude-permit                  │
└────────────────────────────────┘
```

### 手动审批通知
```
┌────────────────────────────────┐
│ 🔔 Claude Permit        (绿色) │
├────────────────────────────────┤
│ 📋 [BASH] Manual approval      │
│ ──────────────────────────────│
│ ⌨️ Cmd                         │
│    docker run -it ubuntu...    │
│ 🔗 Session                     │
│    a1b2c3d4e5f6...             │
├────────────────────────────────┤
│ claude-permit                  │
└────────────────────────────────┘
```

### 文件操作通知
```
┌────────────────────────────────┐
│ 🔔 Claude Permit        (绿色) │
├────────────────────────────────┤
│ 📋 [READ] Manual approval      │
│ ──────────────────────────────│
│ 📁 Path                        │
│    /etc/passwd                 │
│ 🔗 Session                     │
│    e5f6g7h8i9j0...             │
├────────────────────────────────┤
│ claude-permit                  │
└────────────────────────────────┘
```

## 通知触发场景

| 场景 | 分组 | 说明 |
|------|------|------|
| 危险命令被阻断 | `claude-danger` | Critical/High 级别命令被 PreToolUse 阻止 |
| 命令自动批准 | `claude-permit` | 白名单命令被 PermissionRequest 自动批准 |
| 命令等待审批 | `claude-permit` | 非白名单命令需要用户手动确认 |
| Claude 提问/通知 | `claude-question` | Claude 需要用户关注（提问、权限提示等） |
| 任务完成 | `claude-done` | Claude Code 任务执行完毕 |
| 会话停止 | `claude-stop` | 用户主动停止会话 |
| 会话结束 | `claude-stop` | 会话完全结束（SessionEnd） |
| 队友空闲 | `claude-idle` | Agent 队友进入空闲状态 |

## 通知分组 (Bark)

| 分组 | 触发场景 | 默认声音 |
|------|----------|----------|
| `claude-danger` | 危险命令被阻断 | alarm.caf |
| `claude-permit` | 权限待用户审批 | bell.caf |
| `claude-done` | 任务完成 | glass.caf |
| `claude-stop` | 会话停止/结束 | - |
| `claude-idle` | 队友空闲 | - |

## 安全命令白名单

以下命令类别会自动批准：

- **Git**: status, log, diff, add, commit, push, pull, checkout, merge, rebase, branch, fetch, stash, reset, restore, switch, show
- **包管理器**: npm, pnpm, yarn, pip
- **构建工具**: gradle, mvn, cargo
- **文件读取**: ls, cat, grep, find, head, tail, wc, sort, uniq, cut, awk, sed
- **OpenSpec**: 所有 openspec 子命令（list, propose, apply, archive, explore, status, init, new, instructions, update, validate 等）
- **目录操作**: mkdir
- **文件操作**: touch, cp, mv
- **Docker**: ps, ls, images, logs, inspect, stats, top, port, exec, network ls, volume ls
- **Docker Compose**: up, down, logs, ps, build, config (包括 docker compose v2 语法)

可支持配置添加自定义白名单：

```bash
# 在 barnhk.conf 中
SAFE_COMMANDS="^make ^echo"
```

## 项目目录自动批准

barnhk 支持自动批准项目目录下的所有命令。默认启用此功能。

```bash
# 在 barnhk.conf 中
AUTO_APPROVE_PROJECT_COMMANDS=true   # 启用（默认）
AUTO_APPROVE_PROJECT_COMMANDS=false  # 禁用
```

**注意**: 即使启用此功能，危险命令（如 `rm -rf /`、`sudo` 等）仍会被阻止。

## 危险命令等级

| 等级 | 示例命令 |
|------|----------|
| Critical | `rm -rf /`, `dd ... of=/dev/sda`, `mkfs` |
| High | `sudo`, `curl` | `bash`, `chmod -R 777` |
| Medium | `nc -l`, `kill -9 -1`, `pkill -f` |

## 调试

### Transcript 提取调试

如果 `question` 或 `idle_prompt` 通知显示通用内容而非具体内容，可以查看调试日志：

```bash
cat /tmp/barnhk-transcript-debug.log
```

日志内容包括：
- 传入的 transcript 路径和 session ID
- 每行匹配结果
- 提取的文本内容

### 通知类型配置

通知类型支持三种处理模式：

| 模式 | 说明 |
|------|------|
| `skip` | 跳过通知，不发送 |
| `default` | 使用通用消息 |
| `transcript` | 从 transcript 提取具体内容 |

配置示例：
```bash
NOTIFICATION_PERMISSION_PROMPT="skip"    # 跳过，避免与 permission-request.sh 重复
NOTIFICATION_QUESTION="transcript"        # 提取具体问题内容
NOTIFICATION_IDLE_PROMPT="transcript"     # 提取具体等待内容
```

## 配置文件完整示例

```bash
# === 通知通道 ===
BARK_SERVER_URL="https://api.day.app/YOUR_KEY"
DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/..."
FEISHU_WEBHOOK_URL="https://open.feishu.cn/open-apis/bot/v2/hook/..."

# === 通知类型处理 ===
NOTIFICATION_PERMISSION_PROMPT="skip"
NOTIFICATION_QUESTION="transcript"
NOTIFICATION_IDLE_PROMPT="transcript"

# === 安全命令 ===
SAFE_COMMANDS=""

# === 项目目录自动批准 ===
AUTO_APPROVE_PROJECT_COMMANDS=true

# === 远程审批 (cplit) ===
CPLIT_ENABLED=false
CPLIT_URL=""
```
