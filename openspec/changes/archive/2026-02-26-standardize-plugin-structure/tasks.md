## 1. panck 结构重构

- [x] 1.1 创建 `.claude-plugin/plugin.json` manifest
- [x] 1.2 移动 `panck-plugin/SKILL.md` → `SKILL.md`
- [x] 1.3 移动 `panck-plugin/references/` → `references/`
- [x] 1.4 移动 `panck-plugin/assets/` → `assets/`
- [x] 1.5 删除 `panck-plugin/` 目录
- [x] 1.6 删除 panck 原有的 `install.sh` 和 `uninstall.sh`

## 2. barnhk 结构重构

- [x] 2.1 创建 `.claude-plugin/plugin.json` manifest
- [x] 2.2 创建 `hooks/hooks.json`（从 install.sh 提取 hooks 配置）
- [x] 2.3 在 plugin.json 中添加 `"hooks": "./hooks/hooks.json"` 引用
- [x] 2.4 删除 barnhk 原有的 `install.sh` 和 `uninstall.sh`

## 3. cckit 统一管理

- [x] 3.1 创建 cckit 根目录 `.claude-plugin/marketplace.json`
- [x] 3.2 创建 cckit 根目录 `install.sh`（使用 marketplace 方式）
- [x] 3.3 创建 cckit 根目录 `uninstall.sh`（使用 marketplace 方式）

## 4. 文档更新

- [x] 4.1 更新 `standards/plugins/claude-code-plugins.md` 补充 cckit 插件规范
- [x] 4.2 更新 `README.md` 安装说明
- [x] 4.3 更新 `CLAUDE.md` 安装说明

## 5. 验证

- [x] 5.1 测试 barnhk 卸载和重装
