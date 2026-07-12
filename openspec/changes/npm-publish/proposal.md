## Why

当前 cckit 安装流程要求用户 clone 整个仓库再执行 shell 脚本，对新用户门槛高、体验差。npm 是 Node.js 生态最通用的分发方式，`npx @suj1e/cckit` 一行命令即可完成安装，大幅降低使用摩擦。

## What Changes

- 新增 `package.json` 和 `bin/cli.js`，提供 npm 包分发能力
- **BREAKING**: 删除所有旧安装/卸载脚本（`install.sh`、`install.ps1`、`install.bat`、`uninstall.sh`、`uninstall.ps1`），安装方式从脚本改为 CLI
- 更新 `README.md`、`CLAUDE.md` 中的安装说明
- 插件源码（skills/、hooks/、standards/）不做任何修改

## Capabilities

### New Capabilities

- `npm-distribution`: 将 cckit 作为 `@suj1e/cckit` npm 包发布，用户通过 `npx @suj1e/cckit` 或全局安装后 `cckit` 命令安装插件。CLI 支持 install、uninstall、list、update、info 五个子命令。

### Modified Capabilities

<!-- 本次修改不涉及任何现有 spec 的需求变更，只改变安装分发方式 -->

## Impact

- 新增: `package.json`、`bin/cli.js`、`.npmignore`
- 删除: `install.sh`、`install.ps1`、`install.bat`、`uninstall.sh`、`uninstall.ps1`
- 修改: `README.md`、`CLAUDE.md`、`.gitignore`
