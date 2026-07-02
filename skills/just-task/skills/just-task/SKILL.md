---
name: just-task
description: |
  在项目目录下执行 just 命令。长驻命令（run/restart/build/test/watch）以后台 task 跑，瞬完命令（log/st/deps/clean）直接执行。
  触发场景：
  - 用户说 just xxx、跑一下 xxx、执行 just、/just-task
  - 用户说"启动/运行/重启/打包/测试/停止/看日志/状态/依赖树"
  - 任何涉及 justfile 的操作
  只在当前目录或其父目录存在 justfile 时触发。
---

# Just Task Runner

在项目目录下智能执行 just 命令——长驻后台，短命直接返回。

## 核心流程

### 1. 定位项目

从当前工作目录开始逐级向上查找 `justfile`，找到的第一个所在目录即为项目根。如果找不到，告诉用户。

### 2. 读取可用命令

```bash
just --list
```

获取 justfile 所有命令及描述，用于匹配用户意图。

### 3. 匹配意图

用户说自然语言，根据 `just --list` 的命令名和描述做模糊匹配：

| 用户典型说法 | 匹配的 just 命令 |
|-------------|-----------------|
| 启动、运行、run、start | `run` |
| 重启、restart | `restart` |
| 打包、编译、构建、build | `build` |
| 测试、跑测试、test | `test` |
| 停、停止、关掉、stop | 停止后台 task |
| 日志、log、看日志 | `log` |
| 状态、st、status | `st` |
| 依赖、依赖树、deps | `deps` |
| 清理、clean | `clean` |

如果匹配不上，列出可用命令让用户选。

### 4. 智能执行

由命令类型决定执行方式：

| 类型 | 特点 | 执行方式 |
|------|------|---------|
| **长驻** | run, restart, build, test, watch, dev, serve, package | 后台 task（`run_in_background: true`） |
| **瞬完** | log, st, deps, clean, lint, fmt, check, tree, list | 直接执行，输出当场返回 |

判断规则：命令名或描述含 run/start/serve/watch/dev/build/test/package → 后台；其余 → 直接。

用户也可以显式要求"后台跑"或"直接跑"来覆盖默认。

#### 长驻命令

```bash
cd <project-root> && just <command>
```
用 `run_in_background: true`，拿到 task_id 告诉用户。

#### 瞬完命令

```bash
cd <project-root> && just <command>
```
普通执行，输出直接展示。

### 5. 反馈格式

后台任务：
```
✓ just-task: <project-name> → just run  [后台]
  Task ID: abc123

随时说"看输出"或"停掉"。
```

直接执行：正常展示输出，无需额外格式。

## 停止任务

用 `jps -l` 精确定位后 `taskkill`：
```bash
jps -l | Select-String "<main-class>" | ForEach-Object { $pid = ($_ -split '\s+')[0]; taskkill /f /pid $pid 2>$null }
```
如果 justfile 有 `restart` 命令，直接用。

## 多任务管理

可以同时跑多个服务：
- 服务端 `just run` → task_A
- 客户端 `just run` → task_B

用户说"看客户端输出"→ 读 task_B 输出；"停掉服务端"→ kill task_A。

## 注意事项

- 已有一个 `run` task 在跑时，再次 run 先停旧的再启新的
- justfile 有 `restart` 命令时优先使用
- 瞬完命令不需要记录 task，跑了就行
