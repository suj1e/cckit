## 概述

增强 `permission-request.sh` 的通知内容，提供更多上下文信息。

## 技术方案

### 1. 提取更多 JSON 字段

从 PermissionRequest hook 的输入 JSON 中提取：
- `.permission.name` - 权限类型（bash, Read, Write 等）
- `.permission.command` - 命令内容（Bash 工具）
- `.permission.path` - 文件路径（Read/Write 工具）
- `.session_id` - 会话 ID
- `.transcript_path` - 会话记录路径

### 2. 通知内容格式

**自动批准通知:**
```
[工具类型] Auto-approved
命令: <截断后的命令>
```

**手动审批通知:**
```
[工具类型] Manual approval needed
命令: <截断后的命令>
路径: <文件路径，如有>
Session: <会话 ID>
```

### 3. 内容截断

- 命令长度超过 100 字符时截断，添加 `...`
- 保留命令开头部分，便于识别

### 4. 实现位置

修改 `hooks/barnhk/lib/permission-request.sh`：
- 扩展 JSON 字段提取
- 构建详细的通知 body
- 添加截断函数到 `common.sh`
