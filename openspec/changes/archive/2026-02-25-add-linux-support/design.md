## Context

当前 barnhk 的 install.sh 只提供了 macOS 的 jq 安装提示 (`brew install jq`)，对 Linux 用户不友好。脚本本身使用的 bash 语法在 Linux 上是兼容的，只需要改进安装提示信息。

## Goals / Non-Goals

**Goals:**
- 检测操作系统类型 (macOS/Linux)
- 根据操作系统提供对应的 jq 安装命令提示
- 更新 README 说明支持的平台

**Non-Goals:**
- 支持 Windows (WSL 除外)
- 自动安装 jq 依赖
- 修改脚本核心逻辑

## Decisions

### 1. OS 检测方式
**Decision**: 使用 `uname` 命令检测操作系统
**Rationale**: `uname` 是 POSIX 标准命令，在 macOS 和 Linux 上都可用
**Implementation**: `$(uname -s)` 返回 `Darwin` (macOS) 或 `Linux`

### 2. jq 安装提示
**Decision**: 根据操作系统显示不同的安装命令
- macOS: `brew install jq`
- Debian/Ubuntu: `sudo apt install jq`
- RHEL/CentOS: `sudo yum install jq` 或 `sudo dnf install jq`
- 其他 Linux: 显示通用提示

**Rationale**: 不同 Linux 发行版使用不同的包管理器

## Risks / Trade-offs

- **Risk**: 无法检测所有 Linux 发行版
  - **Mitigation**: 提供常见的 apt/yum 命令，并提示用户使用对应包管理器
