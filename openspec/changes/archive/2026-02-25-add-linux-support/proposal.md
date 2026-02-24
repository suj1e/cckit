## Why

当前 install.sh 中的 jq 安装提示只提供了 macOS 的 `brew install jq` 命令，对 Linux 用户不友好。需要让脚本支持 Linux 系统，提供跨平台的安装体验。

## What Changes

- 检测操作系统类型 (macOS/Linux)
- 根据操作系统提供对应的 jq 安装命令提示
- 更新 README.md 添加 Linux 支持说明

## Capabilities

### New Capabilities

- `cross-platform-support`: 脚本支持 macOS 和 Linux 系统

### Modified Capabilities

- `safe-command-auto-approval`: 安装脚本支持跨平台

## Impact

- `hooks/barnhk/install.sh` - 添加 OS 检测和跨平台提示
- `hooks/barnhk/uninstall.sh` - 无需修改（已兼容）
- `hooks/barnhk/README.md` - 添加 Linux 支持说明
