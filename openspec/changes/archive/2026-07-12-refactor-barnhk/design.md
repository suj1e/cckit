## Context

barnhk hook 当前架构：7 个独立脚本 + common.sh（644 行）+ 7 个镜像 .ps1。问题在 5 个维度（样板代码、重复分支、双语言维护、单文件臃肿、零测试）。

## Goals / Non-Goals

**Goals:**
- 消除 hook 脚本样板代码（dispatch_hook 模式）
- 删除所有 PowerShell 文件
- 拆分 common.sh 为单一职责模块
- 建立测试覆盖基础

**Non-Goals:**
- 不改变 hook 行为逻辑（纯重构）
- 不修改 `plugin.json` 中的 hook 路径
- 不动 `barnhk.conf` 配置格式

## Decisions

### 1. dispatch_hook 模式

每个 hook 脚本 5 行：shebang + source common.sh + dispatch_hook。`common.sh` 中的 `dispatch_hook` 统一处理 `load_config`、stdin 读取、`PROJECT_NAME` 提取、调用 `hooks.sh` 中的对应函数。函数命名规则：`hook_<name>`（`hook_pre_tool_use`、`hook_permission_request` 等）。

### 2. 删除 PowerShell

barnhk 作为 npm 分发的插件，用户环境必装 Node.js。Windows 用户安装 Claude Code 自带 Git Bash，`.sh` 可直接执行。删除 8 个文件。

### 3. common.sh 拆分

按职责拆为 5 个文件，`common.sh` 作为入口 source 所有子模块：

| 文件 | 职责 | 行数 |
|------|------|------|
| `common.sh` | 入口 + dispatch_hook + json_value 等工具函数 | ~50 |
| `hooks.sh` | 7 个 hook_* 函数 | ~150 |
| `notify.sh` | Bark + Discord + 飞书 + send_notification | ~350 |
| `safety.sh` | is_safe_command + check_danger_level | ~100 |
| `transcript.sh` | extract_transcript_content | ~80 |

### 4. 测试

`tests/` 目录，零依赖 shell 测试。每个模块一个文件，`source` 被测模块后直接调用函数 assert。后续 CI 可加 test job。

## Risks / Trade-offs

- 删除 .ps1 对纯 Windows 无 Git Bash 用户有影响 → 这类场景极少，Claude Code 安装本身就带 bash
- common.sh 拆分引入多文件 → 每次 source 从 1 次变 5 次，性能影响可忽略（都是内存操作）
