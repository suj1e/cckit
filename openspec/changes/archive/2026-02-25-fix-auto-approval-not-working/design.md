## Context

`permission-request.sh` 在测试时输出正确的 JSON `{"hookSpecificOutput":{"permissionDecision":"allow"}}`，但实际使用时自动审批未生效。

可能的原因：
1. `send_bark_notification` 中的 `curl` 调用可能影响输出
2. 输出顺序问题：通知发送在 JSON 输出之前
3. 某些边缘情况下的输出污染

## Goals / Non-Goals

**Goals:**
- 确保 JSON 输出干净、完整
- JSON 输出应在任何其他操作之前
- 添加调试日志便于排查

**Non-Goals:**
- 不修改通知逻辑
- 不修改安全命令白名单

## Decisions

### 1. JSON 输出顺序

**决定**: 将 JSON 输出移到通知发送之前

**理由**:
- 确保 JSON 是第一个输出到 stdout 的内容
- 避免任何后续操作可能的影响

### 2. 调试日志

**决定**: 添加调试信息输出到 stderr

**理由**:
- stderr 不影响 stdout 的 JSON 输出
- 便于排查问题

### 3. 输出格式

**决定**: 保持现有的 JSON 格式不变

**理由**:
- 格式符合规范
- 测试时输出正确
