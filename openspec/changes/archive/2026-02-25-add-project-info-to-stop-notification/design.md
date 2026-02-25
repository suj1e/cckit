## Context

当前 `stop.sh` 在会话停止时发送通知，但只显示 Session ID 和停止原因。用户无法从通知中快速识别是哪个项目的会话。

根据 Claude Code hooks 的实际输入格式，Stop hook 除了 `session_id` 和 `reason` 外，还会收到 `cwd`（当前工作目录）字段，可以从中提取项目名称。

**当前通知格式：**
```
Session: abc123
Reason: user_requested
```

**期望格式：**
```
📁 cckit
Session: abc123
Reason: user_requested
```

## Goals / Non-Goals

**Goals:**
- 从 `cwd` 字段提取项目名称（最后一级目录名）
- 通知内容第一行显示项目名称，带文件夹图标
- 保持向后兼容：如果 `cwd` 不存在，仍显示原有内容

**Non-Goals:**
- 不修改其他 hook 的通知格式
- 不改变通知触发时机

## Decisions

### 1. 使用 cwd 字段提取项目名

**决定**: 从 `cwd` 字段提取最后一级目录名作为项目名称

**理由**:
- `cwd` 是 Claude Code hooks 的标准输入字段
- 目录名通常是项目名称，直观易懂
- 使用 `basename` 命令简单可靠

**替代方案**: 从 `transcript_path` 提取
- 否决：路径更复杂，提取逻辑更繁琐

### 2. 项目名显示在第一行

**决定**: 通知格式为 `📁 <项目名>` 作为第一行

**理由**:
- 项目名是最重要的识别信息，应该最显眼
- 文件夹图标提供视觉区分
- 与其他通知格式保持一致的图标风格

## Risks / Trade-offs

**Risk**: `cwd` 可能为空或不包含有用信息
→ **Mitigation**: 如果 `cwd` 为空，跳过项目名显示，保持原有格式
