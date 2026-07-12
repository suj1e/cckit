## Why

当前 barnhk 维护 3 个通知后端（Bark + Discord + 飞书），代码量大（`notify.sh` 350 行）、配置繁琐（3 个 URL + 5 个 Discord 颜色 + 飞书卡片逻辑）。切换到 EchoBell webhook 后，通知后端精简为一个 HTTP POST，配置简化为一行 token。同时将配置格式从 `.conf`（bash 变量语法）改为 `.env`（通用标准）。

## What Changes

- 删除 3 个通知后端：Bark、Discord、飞书全部代码
- 新增 `send_echobell_notification`：POST JSON 到 `https://hook.echobell.one/t/{token}`，传 `title` + `body` + `group` 三个变量
- **BREAKING**: 配置格式从 `barnhk.conf` 改为 `barnhk.env`，旧的 3 个 URL + 5 个 Discord 颜色字段删除，新增 `ECHOBELL_TOKEN`
- 更新 `test-notify.sh` 测试
- 更新 `README.md` 配置说明

## Capabilities

### Modified Capabilities

- `barnhk-hooks`: 通知后端从 Bark+Discord+飞书切换为 EchoBell，配置格式从 .conf 改为 .env
