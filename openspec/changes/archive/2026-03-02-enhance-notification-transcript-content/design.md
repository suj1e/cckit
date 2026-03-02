## Context

当前 `notification.sh` 处理所有 Claude Code 的 Notification hook 事件，但只显示通用文案（如 "Claude is waiting for your input"）。用户需要打开终端才能看到具体是什么问题。

同时，`permission_prompt` 类型的通知会与 `permission-request.sh` 发送的通知重复，造成用户收到两条类似的通知。

**Transcript 文件结构：**
- 路径：`~/.claude/projects/<project>/<session-id>.jsonl`
- 每行是一个 JSON 对象，包含 `sessionId`、`type`、`message` 等字段
- `type: "assistant"` 的消息中，`message.content[]` 包含 `type: "text"` 的具体回复内容

## Goals / Non-Goals

**Goals:**
- 从 transcript 提取最后一条 assistant text 作为通知的具体内容
- 添加配置项控制各 notification_type 的处理方式
- 使用 sessionId 验证提取内容属于当前会话
- 避免与 permission-request.sh 的通知重复

**Non-Goals:**
- 不修改其他 hook 脚本
- 不改变通知的发送渠道（Bark/Discord/Feishu）
- 不处理 transcript 文件的写入逻辑

## Decisions

### 1. 配置项设计

在 `barnhk.conf` 中添加三个配置项，控制各类型的处理方式：

```
NOTIFICATION_PERMISSION_PROMPT="skip"    # 跳过，避免重复
NOTIFICATION_QUESTION="transcript"       # 从 transcript 提取
NOTIFICATION_IDLE_PROMPT="transcript"    # 从 transcript 提取
```

可选值：
- `skip` - 不发送通知
- `default` - 使用通用 message 字段
- `transcript` - 从 transcript 提取具体内容

**替代方案：** 使用单一配置项 `NOTIFICATION_ENHANCED_TYPES="question,idle_prompt"`，但这样不够灵活，无法单独控制每个类型。

### 2. Transcript 提取逻辑

```
1. 读取 transcript 文件最后 30 行
2. 倒序遍历，检查每行的 sessionId 是否匹配
3. 找到 type="assistant" 且 content 包含 type="text" 的行
4. 提取 text 内容，截断到 200 字符
5. 如果提取失败，回退到通用 message
```

**替代方案：** 读取整个文件然后过滤，但效率较低。使用 `tac` + `head` 更高效。

### 3. 代码组织

在 `common.sh` 中添加 `extract_transcript_content` 函数，供 `notification.sh` 调用。

**理由：** 提取逻辑可能被其他脚本复用，且保持 notification.sh 简洁。

## Risks / Trade-offs

### 风险 1：时序问题
- **风险：** Notification 触发时，transcript 可能还没写入最新消息
- **缓解：** 这是边缘情况，因为 Notification 通常在 Claude 响应完成后触发；如果提取失败会回退到通用 message

### 风险 2：内容不适用
- **风险：** 最后一条 assistant text 可能是无意义的内容（如 "Done!"）
- **缓解：** 用户可以配置回退到 `default` 模式；后续可以考虑添加内容过滤

### 风险 3：文件读取失败
- **风险：** transcript 文件可能被锁定或损坏
- **缓解：** 所有文件操作都有错误处理，失败时回退到通用 message
