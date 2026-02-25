## Context

当前 cckit 包含两个插件：
- **panck** (skills): Spring Boot 微服务脚手架生成器
- **barnhk** (hooks): 安全防护和多渠道通知

两者都使用自定义 install.sh 脚本，不符合 Claude Code 官方 plugin 规范。

根据 `standards/plugins/claude-code-plugins.md`，标准 plugin 结构：
- 需要 `.claude-plugin/plugin.json` manifest
- skills: `SKILL.md` 在根目录
- hooks: 配置在 `hooks/hooks.json`
- 使用 `${CLAUDE_PLUGIN_ROOT}` 变量处理路径

## Goals / Non-Goals

**Goals:**
- 重构 panck 和 barnhk 目录结构符合官方规范
- 使用 `claude plugin install/uninstall` 命令管理
- 提供统一的 cckit 级别安装/卸载脚本
- 更新规范文档

**Non-Goals:**
- 不改变 panck 和 barnhk 的功能
- 不改变 hooks 的行为逻辑

## Decisions

### 1. panck 目录结构

**决定**: 扁平化结构，移除 `panck-plugin/` 子目录

```
skills/panck/
├── .claude-plugin/
│   └── plugin.json
├── SKILL.md
├── references/
│   └── patterns.md
└── assets/
    └── templates/
```

**理由**: 符合官方规范，SKILL.md 必须在根目录

### 2. barnhk 目录结构

**决定**: 添加 manifest 和 hooks.json

```
hooks/barnhk/
├── .claude-plugin/
│   └── plugin.json
├── hooks/
│   └── hooks.json
├── lib/
│   ├── common.sh
│   ├── barnhk.conf
│   └── *.sh
└── README.md
```

**理由**: hooks.json 是官方支持的 hooks 配置方式，使用 `${CLAUDE_PLUGIN_ROOT}` 自动处理路径

### 3. 统一管理脚本

**决定**: 在 cckit 根目录提供 install.sh 和 uninstall.sh

```bash
# install.sh
#!/bin/bash
# 安装所有 cckit 插件

PLUGINS=(
  "skills/panck"
  "hooks/barnhk"
)

for plugin in "${PLUGINS[@]}"; do
  claude plugin install "$plugin" --scope user
done
```

**理由**:
- 一次命令安装所有插件
- 封装官方命令，简化用户操作
- 支持选择性安装单个插件

### 4. hooks.json 配置

**决定**: 使用 `${CLAUDE_PLUGIN_ROOT}` 变量

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/lib/pre-tool-use.sh"
          }
        ]
      }
    ]
  }
}
```

**理由**: 官方支持的变量，安装路径变化时自动适配

## Risks / Trade-offs

**Risk**: 用户可能不知道新的安装方式
→ **Mitigation**: 更新 README.md 和 CLAUDE.md，说明新的安装流程

**Risk**: 旧版本用户需要手动迁移
→ **Mitigation**: 提供迁移说明，旧 install.sh 可保留为兼容层（提示使用新方式）
