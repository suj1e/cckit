## 1. 白名单扩展

- [x] 1.1 在 `common.sh` 的 `is_safe_command()` 函数中添加 openspec 命令匹配规则
- [x] 1.2 测试 openspec 命令自动审批功能

## 2. 通知标题统一项目名

- [x] 2.1 修改 `pre-tool-use.sh`：添加 cwd 提取和 $PWD fallback 逻辑，传递 project_name 到 send_notification
- [x] 2.2 修改 `permission-request.sh`：添加 cwd 提取和 $PWD fallback 逻辑，传递 project_name 到 send_notification
- [x] 2.3 修改 `task-completed.sh`：添加 cwd 提取和 $PWD fallback 逻辑，传递 project_name 到 send_notification

## 3. 验证

- [x] 3.1 重新安装 barnhk hook 并验证功能正常
- [x] 3.2 验证所有通知类型都显示项目名前缀
