## Context

cckit 目前通过 shell 脚本安装——用户必须 clone 仓库后执行 `./install.sh`。该脚本使用 `dirname "$0"` 定位仓库根目录，将其注册为 Claude Code marketplace，再通过 `claude plugin install <name>@cckit` 安装插件。插件源码全在仓库内，marketplace.json 的 `source` 路径为相对路径（`./skills/jbrick` 等）。

改为 npm 分发后，包安装于 `node_modules/@suj1e/cckit/`，`bin/cli.js` 通过 `__dirname` 定位包根目录，其余流程不变。

## Goals / Non-Goals

**Goals:**
- 用户可以通过 `npx @suj1e/cckit` 一键安装所有插件
- 提供完整的 CLI 命令集：install、uninstall、list、update、info
- 零第三方依赖（只用 Node.js 内置模块）
- 不修改任何插件源码

**Non-Goals:**
- 不改变 barnhk 配置方式（用户仍需手动编辑 barnhk.conf）
- 不实现插件配置的 CLI 交互（如 `cckit config`）
- 不改变 Claude Code 的 marketplace/plugin 机制本身
- 不自动发布到 npm registry（首次发布需手动 `npm publish`）

## Decisions

### 1. Node.js CLI vs Shell 脚本
**选 Node.js**。理由：跨平台（Windows 原生支持无需 WSL/Git Bash），npm `bin` 字段原生支持 Node.js 脚本，`child_process` 模块直接调用 `claude` CLI。Shell 脚本在 Windows 上的体验极差。

### 2. 完整打包 vs 瘦 CLI + 下载
**选完整打包**。npm 包包含所有插件源码（plugins/、skills/、hooks/），CLI 只需注册本地 marketplace。包体积约 50KB，无网络依赖、无版本错配风险、实现更简单。

### 3. 零依赖 vs CLI 框架（commander/yargs）
**选零依赖**。命令只有 5 个，参数解析极简单（`process.argv[2]` 即可），引入框架反而增加维护负担和安全面。用户 `npx` 时也不需要额外下载依赖。

### 4. marketplace 注册时机
**首次安装时注册**。检查 `~/.claude/plugins/known_marketplaces.json` 中是否已有 cckit 条目，有则跳过 `marketplace add`。注册指向 npm 包的安装目录（全局安装稳定，npx 缓存目录每次可能不同，但每次 `npx` 时重新注册即可）。

### 5. install/uninstall 幂等性
`claude plugin install` 若已安装会提示已存在（exit 0），`claude plugin uninstall` 若未安装亦然。CLI 直接透传，不额外做幂等检查。

### 6. 版本发布方式
**选手动 tag 触发 CI 发布**。本地 `npm version patch/minor/major` 打 tag → `git push --follow-tags` → CI 检测到 `v*` tag 自动执行 `npm publish`。不用 conventional commits 自动 bump，保留完全的人为控制——想发版才发，不会因为 merge 几个文档 fix 就意外发布。

### 7. CI/CD 流水线
GitHub Actions，单 workflow 文件 `.github/workflows/publish.yml`：
- 触发条件：push tag 匹配 `v*`
- 步骤：checkout → setup node → `npm install` → `npm pack --dry-run`（验证）→ `npm publish --access public`
- 认证：npm token 存 GitHub Secret `NPM_TOKEN`，CI 运行时注入 `NODE_AUTH_TOKEN`

## Risks / Trade-offs

- **npx 缓存清理风险**：npx 安装到临时缓存目录，系统清理后 marketplace 源路径失效。但 `claude plugin install` 已将插件复制到 `~/.claude/plugins/cache/`，不影响已安装插件。下次 `npx` 时重新注册 marketplace 即可。
- **包名占用**：`@suj1e/cckit` 需确认在 npm registry 上可用。
- **Node.js 版本依赖**：需要 Node.js ≥ 12（`child_process.execSync` 和 `fs`/`path` 均为旧 API），基本所有现代系统都有。
- **旧脚本用户**：删除 install.sh 后，还在用旧方式的用户需要改习惯。影响面小——当前几乎没有外部用户。
