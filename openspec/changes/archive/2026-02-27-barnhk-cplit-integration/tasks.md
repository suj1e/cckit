## 1. Configuration

- [x] 1.1 Add `CPLIT_ENABLED=false` to `barnhk.conf`
- [x] 1.2 Add `CPLIT_URL=""` to `barnhk.conf`
- [x] 1.3 Add documentation comments for new config options

## 2. Common Functions

- [x] 2.1 Add `request_cplit_approval()` function to `common.sh`
- [x] 2.2 Add JSON escaping for command and cwd parameters
- [x] 2.3 Handle curl timeout and error cases

## 3. Permission Request Hook

- [x] 3.1 Add cplit enabled check in `permission-request.sh`
- [x] 3.2 Call `request_cplit_approval()` when cplit is enabled
- [x] 3.3 Output allow JSON when cplit returns "approve"
- [x] 3.4 Output deny JSON when cplit returns "deny"
- [x] 3.5 Fallback to local manual when cplit fails/times out

## 4. Testing

- [x] 4.1 Test with `CPLIT_ENABLED=false` (default behavior)
- [x] 4.2 Test with `CPLIT_ENABLED=true` and valid `CPLIT_URL`
- [x] 4.3 Test with `CPLIT_ENABLED=true` but unreachable cplit server
- [x] 4.4 Test whitelisted command still auto-approves
- [x] 4.5 Test remote approve flow end-to-end
- [x] 4.6 Test remote deny flow end-to-end
