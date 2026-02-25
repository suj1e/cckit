## Why

当前 install.sh 会保护已存在的 barnhk.conf，不覆盖用户配置。但当源配置有新配置项（如 Discord、Feishu webhook）时，用户无法自动获得这些新配置，导致功能缺失或配置不同步。

## What Changes

- 移除 install.sh 中的配置保护逻辑
- 每次运行 install.sh 都直接覆盖 `~/.claude/hooks/barnhk/lib/barnhk.conf`
- **BREAKING**: 用户自定义的配置值会在重新安装时丢失

## Capabilities

### New Capabilities

无。

### Modified Capabilities

无。

## Impact

- **hooks/barnhk/install.sh**: 移除 `if [[ ! -f` 检查，直接复制配置
- **用户**: 需要意识到重新安装会覆盖配置，需要在安装后重新配置
