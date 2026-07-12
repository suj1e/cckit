## Why

精简 cckit 插件集，移除两个使用率低的 skill 插件（jbrick、just-task），减少维护负担和包体积。

## What Changes

- **BREAKING**: 删除 `skills/jbrick/` 和 `skills/just-task/` 目录
- 更新 `marketplace.json`，移除对应 plugin 条目
- 更新 `bin/cli.js` 中的 `ALL_PLUGINS` 和安装提示
- 更新 `README.md`、`CLAUDE.md` 中的插件列表
- 更新 `standards/plugins/claude-code-plugins.md` 中的示例引用

## Capabilities

### Modified Capabilities

- `npm-distribution`: 可安装插件从 4 个减少为 2 个（barnhk、review-merge-sync）

## Impact

- 删除: `skills/jbrick/`、`skills/just-task/`
- 修改: `marketplace.json`、`bin/cli.js`、`README.md`、`CLAUDE.md`、`standards/plugins/claude-code-plugins.md`
