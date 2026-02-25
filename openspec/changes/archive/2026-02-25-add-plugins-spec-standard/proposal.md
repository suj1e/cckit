## Why

项目需要添加 Claude Code 插件系统（Skills、Agents、MCP Servers、LSP Servers）的官方规范文档作为开发标准，确保开发这些扩展时严格遵循官方规范，避免因格式错误或字段缺失导致的兼容性问题。

此前已添加 hooks 规范文档，现在需要补充完整的插件系统规范。

## What Changes

- 新增 `standards/plugins/claude-code-plugins.md` 规范文档
- 文档内容基于官方 https://code.claude.com/docs/en/plugins-reference
- 覆盖所有插件类型：Skills、Agents、Hooks、MCP Servers、LSP Servers
- 包含 plugin.json manifest schema 定义
- 包含插件目录结构规范
- 包含 CLI 命令参考

## Capabilities

### New Capabilities

- `plugins-standard`: Claude Code 插件系统开发规范，包含所有插件类型的 manifest schema、目录结构、CLI 命令等

### Modified Capabilities

(None - this is a new standard documentation)

## Impact

- 新增标准文档，不影响现有代码
- 开发 Skills、Agents 等插件时需遵循此规范
- 与已有的 `standards/hooks/claude-code-hooks.md` 形成完整的标准体系
