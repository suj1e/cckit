## Context

cckit 现有实现仅支持 Unix 平台：安装器 `install.sh` 是 bash、barnhk hooks 是 bash shell 脚本。Windows 用户（Git Bash、PowerShell、CMD 环境）无法获得一键安装体验，hooks 也无法在原生 Windows PowerShell 环境下运行。

当前约束：
- `plugin.json` 中 hook `command` 字段使用 `"${CLAUDE_PLUGIN_ROOT}"/lib/xxx.sh` 格式
- Claude Code 在 Windows 上支持 `.ps1`（PowerShell）和 `.sh`（通过 Git Bash）两种 hook 类型
- Windows 10+ 内置 PowerShell 5.1，Windows 11 内置 PowerShell 7
- 不能改动现有 bash 脚本，Unix 用户路径完全不变

## Goals / Non-Goals

**Goals:**
- Windows 用户可以通过 `install.bat`（双击）或 `install.ps1`（PowerShell）一键安装 cckit 插件
- barnhk hooks 在 Windows 上以 PowerShell 原生运行，不依赖 Git Bash
- PowerShell 版 hooks 功能完全对标 bash 版：危险命令检测、安全命令自动审批、Bark/Discord/飞书三通道通知
- 安装时自动检测平台并选择对应脚本（`.sh` vs `.ps1`）

**Non-Goals:**
- 不改动现有 bash 脚本
- 不支持 Windows CMD 直接运行 hooks（hook 脚本用 PowerShell，CMD 只做安装入口）
- 不新增通知渠道（Bark/Discord/飞书不变）

## Decisions

### 1. 安装器：PowerShell 为主 + CMD 入口

**选择**: `install.ps1` 作为核心安装逻辑，`install.bat` 作为 CMD 双击入口

```bat
@powershell -ExecutionPolicy Bypass -File "%~dp0install.ps1" %*
```

**理由**: PowerShell 可以调用 `claude` CLI、解析 JSON（`ConvertFrom-Json`）、操作注册表和环境变量，远强于 CMD 批处理。`.bat` 仅做一行转发给 `.ps1`。

**替代方案**: 纯 CMD 批处理——功能太弱，处理 JSON/URL/错误重试困难。

### 2. Hook 脚本：PowerShell 原生实现

**选择**: 每个 bash hook 对应一个 `.ps1` 文件，功能完全对标：

| bash | powershell |
|------|------------|
| `pre-tool-use.sh` | `pre-tool-use.ps1` |
| `permission-request.sh` | `permission-request.ps1` |
| `notification.sh` | `notification.ps1` |
| `task-completed.sh` | `task-completed.ps1` |
| `stop.sh` | `stop.ps1` |
| `session-end.sh` | `session-end.ps1` |
| `teammate-idle.sh` | `teammate-idle.ps1` |
| `common.sh` | `common.psm1`（PowerShell 模块） |

**理由**: 文件名一一对应，维护者能快速定位。每个 `.ps1` 独立可测试。

**替代方案**: 单一大脚本用参数分发——不符合 Unix 版的模块化风格。

### 3. 配置：`.psd1` 替代 `.conf`

**选择**: `barnhk.psd1`（PowerShell 数据文件）作为配置，采用 hashtable 格式：

```powershell
@{
    BARK_SERVER_URL = ""
    DISCORD_WEBHOOK_URL = ""
    FEISHU_WEBHOOK_URL = ""
    AUTO_APPROVE_PROJECT_COMMANDS = $true
    NOTIFICATION_QUESTION = "transcript"
    # ...
}
```

**理由**: `.psd1` 是 PowerShell 原生格式，可直接 `Import-PowerShellDataFile` 解析，支持类型安全（bool/string）。比解析 `.conf` 更可靠。

### 4. platform.json 跨平台路径

**选择**: 安装时根据 OS 生成 `plugin.json`：

- Unix 安装：command 指向 `.sh`
- Windows 安装：command 指向 `.ps1`

`install.sh` / `install.ps1` 在安装时负责写入正确路径。

**理由**: Claude Code 的 `plugin.json` 是纯 JSON，不支持条件逻辑或平台分支。与其用不可靠的运行时检测，不如安装时固化。

> **注意**: Claude Code 的 marketplace 安装机制会复制插件到缓存目录。`plugin.json` 中的 `${CLAUDE_PLUGIN_ROOT}` 由 Claude Code 自动解析，因此路径中使用 `"${CLAUDE_PLUGIN_ROOT}"/lib/xxx.ps1` 即可。

### 5. PowerShell 版 hooks 的依赖

**选择**: 零外部依赖。利用 PowerShell 内置功能替代 Unix 工具：

| Unix 工具 | PowerShell 替代 |
|-----------|-----------------|
| `jq` | `ConvertFrom-Json` / `ConvertTo-Json` |
| `curl` | `Invoke-RestMethod` / `Invoke-WebRequest` |
| `tac` | `Get-Content -Tail` 或 `[array]::Reverse()` |
| `sed`/`tr` | `-replace` 运算符 |
| `basename` | `Split-Path -Leaf` |

**理由**: Windows 用户不需要额外安装任何工具，开箱即用。

### 6. 临时文件路径

**选择**: 使用 `$env:TEMP` 替代 `/tmp/`：
- 调试日志：`$env:TEMP\barnhk-*-debug.log`
- Transcript 调试日志：`$env:TEMP\barnhk-transcript-debug.log`

**理由**: `$env:TEMP` 在所有 Windows 系统上存在，无需创建目录。

## Risks / Trade-offs

- **[维护成本] 两套脚本需同步更新**: bash 版改动时需同步更新 PowerShell 版 → 在 `CLAUDE.md` 中明确开发规范，强调两套脚本需同步
- **[PowerShell 版本差异]**: PowerShell 5.1 和 7.x 有 API 差异 → 以 5.1 为基线（Windows 10 内置），避免使用 7.x 专属特性
- **[编码问题]**: Windows 默认 GBK 编码可能导致中文乱码 → 所有 `.ps1` 文件使用 UTF-8 BOM，`install.bat` 使用 `chcp 65001`

## Open Questions

- Claude Code Windows 版 `plugin.json` 中 `${CLAUDE_PLUGIN_ROOT}` 解析为 Windows 风格路径还是 Unix 风格路径？——需要实测验证，两种格式 PowerShell 都能处理
