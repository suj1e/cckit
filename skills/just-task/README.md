# just-task — Just Command Background Runner

在当前项目目录下把 `just` 命令以后台 task 形式运行，支持同时管理多个服务。

## Installation

```bash
./install.sh just-task
```

## Usage in Claude Code

### Slash Command

```
/just-task run        # 启动
/just-task restart    # 重启
/just-task build      # 打包
/just-task test       # 测试
/just-task stop       # 停止
```

### 自然语言

直接说"启动"、"重启服务端"、"打包客户端"、"停掉"即可触发。

## How It Works

1. 从当前目录向上查找 justfile
2. 读取可用命令列表
3. 匹配你的意图 → 执行对应 just 命令
4. 以后台 task 运行，不阻塞对话
5. 支持同时跑多个项目（如服务端 + 客户端）

## Uninstall

```bash
./uninstall.sh just-task
```
