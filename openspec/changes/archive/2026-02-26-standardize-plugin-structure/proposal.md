## Why

当前 panck 和 barnhk 使用自定义 install.sh/uninstall.sh 脚本进行安装管理，不符合 Claude Code 官方 plugin 规范。这导致：
- 管理方式不统一（skills 和 hooks 安装逻辑不同）
- 无法使用官方 `claude plugin` 命令进行安装、卸载、更新
- hooks 需要手动修改 settings.json，容易出错
- 目录结构不符合 standards/plugins/claude-code-plugins.md 规范

## What Changes

### panck (Skills)

- **重构目录结构**：扁平化，移除 `panck-plugin/` 子目录
- **添加 plugin.json manifest**
- **移除组件内的 install.sh/uninstall.sh**

### barnhk (Hooks)

- **重构目录结构**：添加 `.claude-plugin/` 和 `hooks/hooks.json`
- **添加 plugin.json manifest**
- **将 hooks 配置从 settings.json 操作改为 hooks.json 声明式配置**
- **移除组件内的 install.sh/uninstall.sh**

### 新增统一管理脚本

在 cckit 根目录添加 `install.sh` 和 `uninstall.sh`，统一管理所有插件：

```bash
# 安装所有插件
./install.sh

# 安装指定插件
./install.sh panck
./install.sh barnhk

# 卸载
./uninstall.sh barnhk
```

### 更新规范文档

更新 `standards/plugins/claude-code-plugins.md`，补充：
- cckit 插件安装/卸载的标准流程
- 目录结构规范
- hooks.json 配置示例

## Capabilities

### New Capabilities

- `plugin-standard-structure`: Plugin 结构符合 Claude Code 官方规范
- `plugin-cli-management`: 使用官方 `claude plugin` 命令管理插件

### Modified Capabilities

None（这是结构性重构，不影响功能）

## Impact

### cckit 根目录新增
- `install.sh` - 统一安装脚本
- `uninstall.sh` - 统一卸载脚本

### panck 文件变更
- 移动 `panck-plugin/SKILL.md` → `SKILL.md`
- 移动 `panck-plugin/references/` → `references/`
- 移动 `panck-plugin/assets/` → `assets/`
- 新增 `.claude-plugin/plugin.json`
- 删除 `install.sh`、`uninstall.sh`

### barnhk 文件变更
- 新增 `.claude-plugin/plugin.json`
- 新增 `hooks/hooks.json`
- 保留 `lib/` 目录结构
- 删除 `install.sh`、`uninstall.sh`

### standards 文件变更
- 更新 `standards/plugins/claude-code-plugins.md`
