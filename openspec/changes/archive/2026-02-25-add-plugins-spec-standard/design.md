## Context

项目已有 `standards/hooks/claude-code-hooks.md` 作为 hooks 开发的参考规范。现需要补充完整的插件系统规范，覆盖 Skills、Agents、MCP Servers、LSP Servers 等所有插件类型。

官方文档 https://code.claude.com/docs/en/plugins-reference 提供了完整的插件系统说明。

## Goals / Non-Goals

**Goals:**
- 创建 `standards/plugins/claude-code-plugins.md` 规范文档
- 文档结构与 hooks 规范保持一致的风格
- 覆盖所有插件类型的 manifest schema
- 包含目录结构、CLI 命令、troubleshooting 等参考信息

**Non-Goals:**
- 不修改现有代码
- 不创建新的插件实现
- 不翻译官方文档（保留英文原文确保准确性）

## Decisions

### 1. 文档路径选择

**决定**: `standards/plugins/claude-code-plugins.md`

**理由**:
- 与 hooks 规范 (`standards/hooks/claude-code-hooks.md`) 保持一致的目录结构
- 按插件类型分类，便于查找和维护

### 2. 文档内容来源

**决定**: 直接基于官方文档内容，保留英文原文

**理由**:
- 避免翻译带来的歧义
- 官方文档会更新，保留原文便于对照
- 关键部分可添加中文注释说明用途

### 3. 文档结构

**决定**: 按官方文档结构组织，添加目录导航

**结构**:
1. 概述 (Overview)
2. 插件组件 (Skills, Agents, Hooks, MCP Servers, LSP Servers)
3. Plugin Manifest Schema
4. 目录结构
5. CLI 命令参考
6. Troubleshooting

## Risks / Trade-offs

**官方文档更新**: 官方文档可能更新，需要定期同步
→ 缓解：文档顶部注明来源 URL 和版本日期，定期检查更新
