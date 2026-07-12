## Context

当前 cckit 有 4 个插件：jbrick、just-task、barnhk、review-merge-sync。前两个是 skill 插件，使用场景较窄（Spring Boot 脚手架 + just task 执行器），决定移除。

## Goals / Non-Goals

**Goals:**
- 从代码库和 npm 包中完全移除 jbrick、just-task
- 保留 barnhk 和 review-merge-sync 不变

**Non-Goals:**
- 不修改已安装用户的存量插件（卸载需用户手动操作）
- 不改变 CLI 的命令结构

## Decisions

纯删除操作，无架构决策。改动清单已在 proposal 中明确。
