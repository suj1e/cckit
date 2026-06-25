## Why

cckit 目前仅在 Unix (macOS/Linux) 上可用——安装脚本 `install.sh` 是 bash 脚本，barnhk hooks 全部用 bash 编写且存在 `tac`、`/tmp/` 等 Unix 专属依赖，Windows 用户（包括 Git Bash 环境）无法一键安装使用。需要新增 Windows 原生安装器和 PowerShell 版 hooks，让 Windows 开发者获得同等体验。

## What Changes

- 新增 `install.ps1`（PowerShell 安装脚本）和 `install.bat`（CMD 入口，方便双击运行）
- 新增 `uninstall.ps1`（PowerShell 卸载脚本）
- 新增 barnhk hooks 的 PowerShell 版本（`.ps1`），功能对标现有 bash 版
- 新增 `barnhk.psd1`（PowerShell 配置模块），替代 `.conf` 文件的配置方式
- 修改 `plugin.json`，安装时根据平台自动选择 `.sh` 或 `.ps1`
- 更新 `CLAUDE.md` 和 `README.md`，说明 Windows 平台支持

## Capabilities

### New Capabilities

- `windows-installer`: Windows 安装/卸载脚本，支持 PowerShell 和 CMD 两种入口，自动添加 marketplace 并安装插件
- `barnhk-powershell-hooks`: barnhk hooks 的 PowerShell 实现，功能完全对标 bash 版（PreToolUse/PermissionRequest/Notification/TaskCompleted/Stop/SessionEnd/TeammateIdle），支持 Bark/Discord/飞书三通道通知

### Modified Capabilities

- `barnhk-hooks`: plugin.json 的 hook command 需要支持跨平台路径解析，安装时根据操作系统选择执行 `.sh` 或 `.ps1`

## Impact

- **Affected code**: `install.sh`（无改动），`hooks/barnhk/.claude-plugin/plugin.json`（修改 command 路径），新增 `install.ps1`、`install.bat`、`uninstall.ps1`，新增 `hooks/barnhk/lib/*.ps1`、`hooks/barnhk/lib/barnhk.psd1`
- **Dependencies**: Windows 用户需要 PowerShell 5.1+（Windows 10+ 内置），jq 在 PowerShell 版中不再需要（改用 `ConvertFrom-Json`），curl 在 Windows 10+ 内置
- **No breaking changes**: 现有 Unix 路径和行为完全不变
