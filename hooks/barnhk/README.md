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
| 🔔 **多通道通知** | 支持 Bark (iOS) 和 Discord Webhook |

## Hooks 类型

| Hook | 触发时机 | 功能 |
|------|----------|------|
| `PreToolUse` | 执行工具之前 | 危险命令检测与阻断 |
| `PermissionRequest` | 请求权限时 | 安全命令自动审批 + 通知 |
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

barnhk 支持两种通知通道，可同时配置：

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

Discord 支持 Embed 富文本格式，不同类型通知有不同颜色：

| 分组 | 颜色 | 说明 |
|------|------|------|
| `claude-danger` | 🔴 红色 | 危险命令被阻断 |
| `claude-permit` | 🟢 绿色 | 权限审批 |
| `claude-done` | 🔵 蓝色 | 任务完成 |
| `claude-stop` | 🟠 橙色 | 会话停止 |
| `claude-idle` | ⚪ 灰色 | 队友空闲 |

可自定义颜色（十进制值）：
```bash
DISCORD_COLOR_DANGER="15548997"
DISCORD_COLOR_PERMIT="5763719"
DISCORD_COLOR_DONE="3066993"
DISCORD_COLOR_STOP="15105570"
DISCORD_COLOR_IDLE="8421504"
```

## 通知格式示例

### 自动批准通知
```
[BASH] Auto-approved
Cmd: git status
```

### 手动审批通知
```
[BASH] Manual approval needed
Cmd: docker run -it ubuntu...
Session: a1b2c3d4
```

### 文件操作通知
```
[READ] Manual approval needed
Path: /etc/passwd
Session: e5f6g7h8
```

## 通知触发场景

| 场景 | 分组 | 说明 |
|------|------|------|
| 危险命令被阻断 | `claude-danger` | Critical/High 级别命令被 PreToolUse 阻止 |
| 命令自动批准 | `claude-permit` | 白名单命令被 PermissionRequest 自动批准 |
| 命令等待审批 | `claude-permit` | 非白名单命令需要用户手动确认 |
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

- **Git**: status, log, diff, add, commit, push, pull, checkout, merge, rebase
- **包管理器**: npm, pnpm, yarn, pip
- **构建工具**: gradle, mvn, cargo
- **文件读取**: ls, cat, grep, find, head, tail

可支持配置添加自定义白名单：

```bash
# 在 barnhk.conf 中
SAFE_COMMANDS="^make ^docker-compose"
```

## 危险命令等级

| 等级 | 示例命令 |
|------|----------|
| Critical | `rm -rf /`, `dd ... of=/dev/sda`, `mkfs` |
| High | `sudo`, `curl` | `bash`, `chmod -R 777` |
| Medium | `nc -l`, `kill -9 -1`, `pkill -f` |
