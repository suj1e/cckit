## Why

barnhk 代码库存在明显的技术债务：7 个 hook 脚本重复大量样板、common.sh 臃肿（644 行）、.sh/.ps1 双维护负担重、零测试覆盖。需要一次结构性重构提升可维护性。

## What Changes

- 消除 7 个 hook 脚本中重复的样板代码（`dispatch_hook` 模式）
- 合并 `pre-tool-use.sh` 中 `critical`/`high` 的重复分支
- **BREAKING**: 删除全部 PowerShell 脚本（8 个：`*.ps1` × 7 + `common.psm1` + `barnhk.psd1`），barnhk 改为纯 bash
- 拆分 `common.sh`（644 行 → 5 个单文件模块）
- 新增 `tests/` 目录，shell 脚本直测

## Capabilities

### New Capabilities

- `barnhk-tests`: barnhk hook 测试覆盖，包括安全检查、通知、hook 输入输出

### Modified Capabilities

- `barnhk-hooks`: 重构 hook 脚本架构（`dispatch_hook` 模式），移除 PowerShell 支持，拆分 common.sh

## Impact

- 重写: `lib/common.sh`
- 新增: `lib/hooks.sh`、`lib/notify.sh`、`lib/safety.sh`、`lib/transcript.sh`、`tests/` × 3
- 精简: 7 个 `*.sh` 入口（~350 行 → ~35 行）
- 删除: 8 个 PowerShell 文件
- 不变: `plugin.json`、`barnhk.conf`、`README.md`
- 更新: `CLAUDE.md`（删除 PowerShell 跨平台开发说明）
