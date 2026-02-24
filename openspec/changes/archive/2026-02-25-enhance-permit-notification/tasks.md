## 1. 增强 common.sh

- [x] 1.1 Add `truncate_string` function to common.sh for command truncation

## 2. 修改 permission-request.sh

- [x] 2.1 Extract additional JSON fields (session_id, tool path)
- [x] 2.2 Build detailed notification body with tool type prefix
- [x] 2.3 Add session ID to manual approval notifications
- [x] 2.4 Truncate long commands in notifications

## 3. 测试

- [x] 3.1 Test auto-approval notification format
- [x] 3.2 Test manual approval notification format
- [x] 3.3 Test long command truncation
