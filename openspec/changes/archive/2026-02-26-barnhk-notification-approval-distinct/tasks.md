## 1. 配置和颜色映射

- [x] 1.1 在 `barnhk.conf` 添加 `TITLE_APPROVAL="🔐 Claude Approval"`
- [x] 1.2 在 `common.sh` 的 `get_discord_color()` 添加 `claude-auto-permit` 和 `claude-manual-permit` 颜色映射
- [x] 1.3 在 `common.sh` 的 `get_feishu_color()` 添加 `claude-auto-permit` 和 `claude-manual-permit` 颜色映射

## 2. 通知逻辑修改

- [x] 2.1 修改 `permission-request.sh`：auto-approved 使用 `claude-auto-permit` group 和 `TITLE_PERMIT`
- [x] 2.2 修改 `permission-request.sh`：manual approval 使用 `claude-manual-permit` group 和 `TITLE_APPROVAL`

## 3. 验证

- [x] 3.1 重新安装 barnhk hook
- [x] 3.2 验证 auto-approved 和 manual approval 通知使用不同的颜色和标题
