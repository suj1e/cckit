# @suj1e/cckit

![npm version](https://img.shields.io/npm/v/@suj1e/cckit)
![license](https://img.shields.io/npm/l/@suj1e/cckit)

Claude Code 扩展集合 — 一组开箱即用的 skills 和 hooks。

## 安装

```bash
npx @suj1e/cckit
```

一行命令，安装全部 4 个插件。无需 clone，无需脚本。

也可以全局安装后直接用 `cckit` 命令：

```bash
npm install -g @suj1e/cckit
cckit install
```

## CLI 命令

```bash
cckit                   # 安装全部插件（默认）
cckit install [name]    # 安装全部或指定插件
cckit uninstall [name]  # 卸载
cckit list              # 查看已安装插件及状态
cckit update [name]     # 更新插件
cckit info <name>       # 查看插件详情
```

## 插件

### Skills

| 插件 | 用途 |
|------|------|
| **jbrick** | Spring Boot 微服务脚手架生成器，3-module Repository 架构 |
| **just-task** | 后台 just 命令执行器，支持长驻（run/build/test）和短命令 |
| **review-merge-sync** | 代码审查 → 合并 → 推送 → 同步 worktree 工作流 |

### Hooks

| 插件 | 用途 |
|------|------|
| **barnhk** | 安全防护 + 多通道通知（Bark / Discord / 飞书），自动批准安全命令，拦截危险操作 |

## 用法示例

```bash
# 只装 barnhk 钩子
npx @suj1e/cckit install barnhk

# 查看已安装的插件
cckit list

# 更新全部插件
cckit update

# 卸载
npx @suj1e/cckit uninstall barnhk
```

## 更新

```bash
npm update -g @suj1e/cckit   # 更新 CLI
cckit update                  # 更新插件
```

## 链接

- [GitHub](https://github.com/suj1e/cckit) — 源码、问题反馈
- [插件开发规范](./standards/) — 自定义 skill / hook 的参考文档

## License

MIT
