# Design: Extend Safe Commands Whitelist

## Goals

- 简化常见操作的工作流，减少不必要的审批步骤
- 保持安全性，只添加真正安全的命令
- 提升开发体验，特别是容器开发场景
- **git push 前自动更新文档内容**

## Non-Goals

- 不添加可能有危险的命令（如 `rm -rf`、`sudo`、`docker system prune` 等）
- 不修改危险命令检测逻辑
- 不添加可能修改系统的 docker 命令（如 `docker rm -f`、`docker rmi -f`）

## Current State

```bash
# 当前 is_safe_command() 函数的白名单

# Git commands
^git[[:space:]]+(status|log|diff|add|commit|push|pull|...|show)

# Package managers
^(npm|pnpm|yarn|pip)[[:space:]]+(install|run|test|build|start|dev|ci)

# Build tools
^(gradle|mvn|cargo)[[:space:]]

# File read operations
^(ls|cat|grep|find|head|tail|wc|sort|uniq|cut|awk|sed)[[:space:]]

# OpenSpec (不完整 - 只有部分子命令)
^openspec[[:space:]]+(list|propose|apply|archive|explore|status|init|new)
```

## Decisions

### Decision 1: 使用通配符匹配所有 openspec 命令

**Rationale:** OpenSpec 是项目管理工作流工具，所有子命令都是安全的。

**实现:**
```bash
^openspec[[:space:]]+
```

### Decision 2: 添加目录和文件操作命令

**添加的命令:**
| 命令 | 说明 |
|------|------|
| `mkdir` | 创建目录 |
| `touch` | 创建文件/更新时间戳 |
| `cp` | 复制文件 |
| `mv` | 移动/重命名 |

**实现:**
```bash
^mkdir[[:space:]]+
^touch[[:space:]]+
^cp[[:space:]]+
^mv[[:space:]]+
```

### Decision 3: 添加 Docker 只读和常用开发命令

**实现:**
```bash
# Docker read-only and common dev commands
^docker[[:space:]]+(ps|ls|images|logs|inspect|stats|top|port|exec)[[:space:]]+
^docker[[:space:]]+(network|volume)[[:space:]]+ls
^docker-compose[[:space:]]+(up|down|logs|ps|build|config)[[:space:]]+
```

### Decision 4: 在 CLAUDE.md 添加工作流规则

**Rationale:** Hook 只能批准/拒绝命令，无法触发 Claude 执行操作。通过在 CLAUDE.md 中添加工作流规则，让 Claude 在执行 git push 前自动遵循这个流程。

**添加到 CLAUDE.md 的内容:**
```markdown
## Workflow

### Before git push

When user asks to push or commit changes:
1. **Check if docs need updates** - Review README.md and CLAUDE.md
2. **Update docs if needed** - Reflect significant changes in documentation
3. **Stage and commit docs** - `git add README.md CLAUDE.md && git commit -m "docs: update documentation"`
4. **Then push** - Proceed with the original push command
```

**文件修改:**
- `CLAUDE.md` - 添加 Workflow section

### Decision 5: 项目目录命令自动批准开关

**Rationale:** 在受信任的项目目录内，理论上不会有危险操作。提供一个开关让用户可以自动批准当前项目目录下的所有命令。

**配置选项:**
```bash
# Auto-approve all commands within project directory (default: true)
AUTO_APPROVE_PROJECT_COMMANDS=true
```

**实现逻辑:**
```bash
# In is_safe_command() function
if [[ "$AUTO_APPROVE_PROJECT_COMMANDS" == "true" ]]; then
    local cwd="${TOOL_INPUT_CWD:-$(pwd)}"
    local project_root="${TOOL_INPUT_PROJECT_ROOT:-$(pwd)}"
    # If command is executed within project directory, auto-approve
    if [[ "$cwd" == "$project_root"* ]]; then
        return 0
    fi
fi
```

**注意:** 这个开关只影响项目目录内的命令，全局危险命令（如 `rm -rf /`、`sudo` 等）仍然会被阻止。

## Risks / Trade-offs

| 风险 | 缓解措施 |
|------|----------|
| `mv` 可能覆盖文件 | 用户责任 |
| `docker exec` 可能在容器内执行危险操作 | 限制在容器内 |
| Claude 可能忘记更新文档 | CLAUDE.md 中记录期望行为 |
