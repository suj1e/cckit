# Claude Code Status Line 规范

> 来源：[Claude Code Status Line 文档](https://code.claude.com/docs/en/statusline)
>
> ⚠️ 此文档为 cckit 项目内部参考整理，官方文档会持续更新。如有疑问或发现差异，请以官方文档为准。

## 概述

Status line 是 Claude Code 底部可自定义的状态栏，运行任意 shell 脚本，接收 JSON 会话数据（stdin），显示脚本 stdout 输出。用于监控上下文窗口、成本、git 状态等。

Status line 渲染在界面底部 footer badges 上方独立行，不替换内置徽章。

## 配置方式

### 方式一：`/statusline` 命令（推荐）

```text
/statusline show model name and context percentage with a progress bar
```

Claude Code 自动生成脚本到 `~/.claude/` 并更新 settings。

### 方式二：手动配置

在 `~/.claude/settings.json` 或项目 `.claude/settings.json` 中添加：

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh",
    "padding": 2
  }
}
```

**字段说明**：

| 字段 | 类型 | 说明 |
|------|------|------|
| `type` | string | 固定值 `"command"` |
| `command` | string | 脚本路径或内联 shell 命令 |
| `padding` | number (可选) | 额外水平间距（字符数），默认 `0` |
| `refreshInterval` | number (可选) | 定时刷新间隔（秒），最小 `1`，用于时间数据或后台 subagent 变更场景 |
| `hideVimModeIndicator` | boolean (可选) | 设为 `true` 可隐藏内置 `-- INSERT --` 文本（当脚本自行渲染 `vim.mode` 时） |

### 禁用 status line

```bash
/statusline delete
```

或手动删除 settings 中的 `statusLine` 字段。

## 工作原理

Claude Code 通过 **stdin** 向脚本发送 JSON 会话数据，脚本读取 JSON、提取所需字段，向 **stdout** 打印文本。Claude Code 显示 stdout 内容。

### 触发时机

脚本在以下事件后自动运行，并做 300ms 防抖：

- 每次新的 assistant 消息后
- `/compact` 完成后
- 权限模式变更时
- vim 模式切换时

> 注意：若主 session 空闲（如等待后台 subagent），定时触发器会停止。使用 `refreshInterval` 保持刷新。

### 输出能力

- **多行输出**：每个 `echo`/`print` 产生独立行
- **颜色**：使用 ANSI 转义码（如 `\033[32m` 绿色，`\033[0m` 重置）
- **链接**：使用 OSC 8 转义序列实现可点击链接（Cmd+click / Ctrl+click）
- **终端宽度**：使用 `COLUMNS` 和 `LINES` 环境变量（v2.1.153+），不要用 `tput cols`

### 性能要求

- 脚本必须快速返回（< 100ms）
- 避免阻塞命令（如 `git status`、`git diff`），使用缓存（见下方示例）
- 非零退出码或空输出会导致 status line 变空白
- 运行中的脚本被新事件触发时会取消

## 可用数据（JSON schema）

Claude Code 通过 stdin 发送以下 JSON 结构：

```json
{
  "cwd": "/current/working/directory",
  "session_id": "abc123...",
  "session_name": "my-session",
  "prompt_id": "550e8400-e29b-41d4-a716-446655440000",
  "transcript_path": "/path/to/transcript.jsonl",
  "model": {
    "id": "claude-opus-4-8",
    "display_name": "Opus"
  },
  "workspace": {
    "current_dir": "/current/working/directory",
    "project_dir": "/original/project/directory",
    "added_dirs": [],
    "git_worktree": "feature-xyz",
    "repo": {
      "host": "github.com",
      "owner": "anthropics",
      "name": "claude-code"
    }
  },
  "version": "2.1.90",
  "output_style": {
    "name": "default"
  },
  "cost": {
    "total_cost_usd": 0.01234,
    "total_duration_ms": 45000,
    "total_api_duration_ms": 2300,
    "total_lines_added": 156,
    "total_lines_removed": 23
  },
  "context_window": {
    "total_input_tokens": 15500,
    "total_output_tokens": 1200,
    "context_window_size": 200000,
    "used_percentage": 8,
    "remaining_percentage": 92,
    "current_usage": {
      "input_tokens": 8500,
      "output_tokens": 1200,
      "cache_creation_input_tokens": 5000,
      "cache_read_input_tokens": 2000
    }
  },
  "exceeds_200k_tokens": false,
  "fast_mode": false,
  "effort": {
    "level": "high"
  },
  "thinking": {
    "enabled": true
  },
  "rate_limits": {
    "five_hour": {
      "used_percentage": 23.5,
      "resets_at": 1738425600
    },
    "seven_day": {
      "used_percentage": 41.2,
      "resets_at": 1738857600
    }
  },
  "vim": {
    "mode": "NORMAL"
  },
  "agent": {
    "name": "security-reviewer"
  },
  "pr": {
    "number": 1234,
    "url": "https://github.com/anthropics/claude-code/pull/1234",
    "review_state": "pending"
  },
  "worktree": {
    "name": "my-feature",
    "path": "/path/to/.claude/worktrees/my-feature",
    "branch": "worktree-my-feature",
    "original_cwd": "/path/to/project",
    "original_branch": "main"
  }
}
```

### 字段说明

| 字段 | 说明 |
|------|------|
| `model.id`, `model.display_name` | 当前模型 ID 和显示名称 |
| `cwd`, `workspace.current_dir` | 当前工作目录（两者值相同，`workspace.current_dir` 为推荐字段） |
| `workspace.project_dir` | Claude Code 启动目录，可能与 `cwd` 不同 |
| `workspace.added_dirs` | 通过 `/add-dir` 添加的额外目录，空数组表示无 |
| `workspace.git_worktree` | 当前目录所在的 git worktree 名称（主工作树中不存在此字段） |
| `workspace.repo.host`, `.owner`, `.name` | 从 `origin` remote 解析的仓库信息 |
| `cost.total_cost_usd` | 当前 session 预估成本（USD），`/clear` 后重置 |
| `cost.total_duration_ms` | session 总耗时（毫秒） |
| `cost.total_api_duration_ms` | API 响应等待总时间（毫秒） |
| `cost.total_lines_added`, `.removed` | 代码变更行数 |
| `context_window.total_input_tokens` | 当前上下文输入 token 数 |
| `context_window.total_output_tokens` | 当前上下文输出 token 数 |
| `context_window.context_window_size` | 最大上下文窗口大小（默认 200000） |
| `context_window.used_percentage` | 上下文使用百分比 |
| `context_window.remaining_percentage` | 上下文剩余百分比 |
| `context_window.current_usage` | 上次 API 调用的 token 明细 |
| `exceeds_200k_tokens` | 总 token 数是否超过 200k |
| `fast_mode` | 当前 session 是否启用 fast mode |
| `effort.level` | 推理强度（`low` / `medium` / `high` / `xhigh` / `max`） |
| `thinking.enabled` | 是否启用扩展思考 |
| `rate_limits.five_hour.used_percentage` | 5 小时速率限制使用百分比 |
| `rate_limits.seven_day.used_percentage` | 7 天速率限制使用百分比 |
| `session_id` | 唯一 session ID |
| `session_name` | session 名称（自定义名称或 AI 生成标题） |
| `prompt_id` | 当前处理的用户 prompt UUID（v2.1.196+） |
| `transcript_path` | 对话 transcript 文件路径 |
| `version` | Claude Code 版本号 |
| `output_style.name` | 当前输出风格名称 |
| `vim.mode` | vim 模式（`NORMAL` / `INSERT` / `VISUAL` / `VISUAL LINE`） |
| `agent.name` | agent 名称（`--agent` 模式） |
| `pr.number`, `pr.url`, `pr.review_state` | 当前分支的 PR 信息 |
| `worktree.*` | `--worktree` session 的 worktree 信息 |

### 字段可空性

**可能为 `null` 的字段**：

- `context_window.current_usage`：首次 API 调用前、`/compact` 后重新调用前
- `context_window.used_percentage` / `remaining_percentage`：session 早期

**可能完全缺失的字段**：

- `session_name`：无自定义名称且无 AI 生成标题时
- `prompt_id`：首次用户输入前
- `workspace.git_worktree`：不在 linked worktree 中
- `workspace.repo`：不在 git 仓库或无 origin remote
- `effort`：当前模型不支持 effort 参数
- `vim`：vim mode 未启用
- `agent`：未使用 `--agent` 模式
- `pr` / `pr.review_state`：无开放 PR 或 PR 已合并/关闭
- `worktree`：非 `--worktree` session
- `rate_limits`：Claude.ai 订阅用户（Pro/Max）首次 API 响应后才出现

### 最佳实践

脚本应始终处理字段缺失和 null 值：

```bash
# jq 中使用 // 提供默认值
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0')

# 使用 // empty 处理可能完全缺失的字段
FIVE_H=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
```

## 常见示例

### 示例 1：上下文窗口进度条

```bash
#!/bin/bash
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)

BAR_WIDTH=10
FILLED=$((PCT * BAR_WIDTH / 100))
EMPTY=$((BAR_WIDTH - FILLED))
BAR=""
[ "$FILLED" -gt 0 ] && printf -v FILL "%${FILLED}s" && BAR="${FILL// /▓}"
[ "$EMPTY" -gt 0 ] && printf -v PAD "%${EMPTY}s" && BAR="${BAR}${PAD// /░}"

echo "[$MODEL] $BAR $PCT%"
```

### 示例 2：Git 状态 + 颜色

```bash
#!/bin/bash
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name')
DIR=$(echo "$input" | jq -r '.workspace.current_dir')

GREEN='\033[32m'
YELLOW='\033[33m'
RESET='\033[0m'

if git rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=$(git branch --show-current 2>/dev/null)
    STAGED=$(git diff --cached --numstat 2>/dev/null | wc -l | tr -d ' ')
    MODIFIED=$(git diff --numstat 2>/dev/null | wc -l | tr -d ' ')

    GIT_STATUS=""
    [ "$STAGED" -gt 0 ] && GIT_STATUS="${GREEN}+${STAGED}${RESET}"
    [ "$MODIFIED" -gt 0 ] && GIT_STATUS="${GIT_STATUS}${YELLOW}~${MODIFIED}${RESET}"

    echo -e "[$MODEL] 📁 ${DIR##*/} | 🌿 $BRANCH $GIT_STATUS"
else
    echo "[$MODEL] 📁 ${DIR##*/}"
fi
```

### 示例 3：多行综合

```bash
#!/bin/bash
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name')
DIR=$(echo "$input" | jq -r '.workspace.current_dir')
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
DURATION_MS=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')

CYAN='\033[36m'; GREEN='\033[32m'; YELLOW='\033[33m'; RED='\033[31m'; RESET='\033[0m'

if [ "$PCT" -ge 90 ]; then BAR_COLOR="$RED"
elif [ "$PCT" -ge 70 ]; then BAR_COLOR="$YELLOW"
else BAR_COLOR="$GREEN"; fi

FILLED=$((PCT / 10)); EMPTY=$((10 - FILLED))
printf -v FILL "%${FILLED}s"; printf -v PAD "%${EMPTY}s"
BAR="${FILL// /█}${PAD// /░}"

MINS=$((DURATION_MS / 60000)); SECS=$(((DURATION_MS % 60000) / 1000))

BRANCH=""
git rev-parse --git-dir > /dev/null 2>&1 && BRANCH=" | 🌿 $(git branch --show-current 2>/dev/null)"

echo -e "${CYAN}[$MODEL]${RESET} 📁 ${DIR##*/}$BRANCH"
COST_FMT=$(printf '$%.2f' "$COST")
echo -e "${BAR_COLOR}${BAR}${RESET} ${PCT}% | ${YELLOW}${COST_FMT}${RESET} | ⏱️ ${MINS}m ${SECS}s"
```

### 示例 4：缓存昂贵操作

使用 `session_id` 作为缓存文件名的一部分（session 内稳定、跨 session 唯一）：

```bash
#!/bin/bash
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name')
DIR=$(echo "$input" | jq -r '.workspace.current_dir')
SESSION_ID=$(echo "$input" | jq -r '.session_id')

CACHE_FILE="/tmp/statusline-git-cache-$SESSION_ID"
CACHE_MAX_AGE=5

cache_is_stale() {
    [ ! -f "$CACHE_FILE" ] || \
    [ $(( $(date +%s) - $(stat -c %Y "$CACHE_FILE" 2>/dev/null || stat -f %m "$CACHE_FILE" 2>/dev/null || echo 0) )) -gt $CACHE_MAX_AGE ]
}

if cache_is_stale; then
    if git rev-parse --git-dir > /dev/null 2>&1; then
        BRANCH=$(git branch --show-current 2>/dev/null)
        STAGED=$(git diff --cached --numstat 2>/dev/null | wc -l | tr -d ' ')
        MODIFIED=$(git diff --numstat 2>/dev/null | wc -l | tr -d ' ')
        echo "$BRANCH|$STAGED|$MODIFIED" > "$CACHE_FILE"
    else
        echo "||" > "$CACHE_FILE"
    fi
fi

IFS='|' read -r BRANCH STAGED MODIFIED < "$CACHE_FILE"

if [ -n "$BRANCH" ]; then
    echo "[$MODEL] 📁 ${DIR##*/} | 🌿 $BRANCH +$STAGED ~$MODIFIED"
else
    echo "[$MODEL] 📁 ${DIR##*/}"
fi
```

## Subagent Status Line

`subagentStatusLine` 配置自定义 subagent 面板中每行的显示内容。

```json
{
  "subagentStatusLine": {
    "type": "command",
    "command": "~/.claude/subagent-statusline.sh"
  }
}
```

脚本接收包含所有可见 subagent 行的 JSON 对象（stdin），结构包含 `tasks` 数组，每个 task 有：

- `id`, `name`, `type`, `status`, `description`, `label`
- `startTime`, `model`, `contextWindowSize`, `tokenCount`, `tokenSamples`, `cwd`

每行输出一行 JSON：

```json
{"id": "<task-id>", "content": "<自定义行内容>"}
```

- `content` 为空字符串 → 隐藏该行
- 省略某 task 的 `id` → 保留默认渲染

## 故障排查

**Status line 不显示**

- 确认脚本有执行权限：`chmod +x ~/.claude/statusline.sh`
- 确认脚本输出到 stdout 而非 stderr
- 手动运行脚本验证有输出
- Windows 上使用正斜杠路径
- 检查 `disableAllHooks` 是否为 `true`
- `claude --debug` 查看 status line 日志

**显示空值**

- 字段在首次 API 调用前可能为 `null`
- 使用 jq fallback：`.context_window.used_percentage // 0`
- 多次消息后仍为空则重启 Claude Code

**上下文百分比异常**

- 使用 `used_percentage`（基于 input tokens 计算）
- 与 `/context` 的输出可能存在计算时机差异

**OSC 8 链接不可点击**

- 确认终端支持 OSC 8（iTerm2、Kitty、WezTerm）
- Terminal.app 不支持
- Windows Terminal 可能需要 `FORCE_HYPERLINK=1`

**工作区信任要求**

- Status line 需要接受 workspace trust dialog
- 未接受时 status line 保持空白
- 重启 Claude Code 并接受 trust dialog

## 社区工具

- [ccstatusline](https://github.com/sirmalloc/ccstatusline) — 预置配置 + 主题
- [starship-claude](https://github.com/martinemde/starship-claude) — Starship prompt 集成

## cckit statusline 插件

cckit 提供了一个开箱即用的 statusline 插件，安装后自动配置。

### 安装

```bash
npx @suj1e/cckit install statusline
```

### 插件结构

```
plugins/statusline/
├── .claude-plugin/
│   └── plugin.json          # 插件元数据（含 settings 对象）
├── scripts/
│   └── statusline.sh        # 状态栏脚本
├── settings.json            # 参考配置（供用户复制到 settings.json）
└── README.md
```

### 工作原理

- `cckit install statusline` 会将 `scripts/statusline.sh` 部署到 `~/.claude/cckit/statusline.sh`
- 自动将 `statusLine` 配置注入 `~/.claude/settings.json`
- `cckit uninstall statusline` 会同步清理脚本和配置
- 手动安装时，需将 `settings.json` 内容复制到 `~/.claude/settings.json`
- `scripts/statusline.sh` 通过 stdin 接收 JSON 会话数据，输出多行格式化文本
- Git 信息按 session 缓存 5 秒，避免每次刷新都执行 git 命令
- 上下文进度条根据使用百分比变色：绿色 < 70%，黄色 70-89%，红色 ≥ 90%

### 注意事项

- `cckit install` 会自动完成脚本部署和 settings 注入，无需手动操作
- 安装前确保没有已有的 `statusLine` 配置（CLI 检测到已有配置会跳过注入）
- 手动安装或更新插件缓存后，需重新运行 `cckit install statusline` 部署最新脚本
- 依赖 `jq` 进行 JSON 解析，依赖 `git`（可选）显示分支信息

### 参考

- 脚本源码：`statusline/scripts/statusline.sh`
- 插件配置：`statusline/settings.json`
- 官方规范：[Claude Code Status Line 文档](https://code.claude.com/docs/en/statusline)
