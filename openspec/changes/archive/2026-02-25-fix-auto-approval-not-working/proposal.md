## Why

Barnhk 的自动审批功能未生效：用户收到 "Auto-approved" 通知，但实际仍需手动审批。

经过排查，脚本在独立测试时输出正确的 JSON，但在 Claude Code 实际调用时可能存在问题。

## What Changes

- 确保 JSON 输出在通知发送之前，避免任何潜在的输出污染
- 添加调试日志输出到 stderr，便于排查问题
- 确保脚本退出前 stdout 已正确刷新

## Capabilities

### New Capabilities

(None)

### Modified Capabilities

(None)

## Impact

- 仅修改 `hooks/barnhk/lib/permission-request.sh`
- 不影响通知功能
