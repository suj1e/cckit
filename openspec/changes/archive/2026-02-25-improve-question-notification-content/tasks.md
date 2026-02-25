## 1. Code Changes

- [x] 1.1 Modify notification.sh to display message field for all notification types
- [x] 1.2 Add icon prefix based on notification_type (🔐 for permission_prompt, ❓ for question, 🔔 for others)
- [x] 1.3 Add message truncation (max 200 characters with "..." suffix)

## 2. Documentation

- [x] 2.1 Update standards/hooks/claude-code-hooks.md with Notification hook section including input fields (message, title, notification_type)
- [x] 2.2 Reinstall barnhk hooks to apply changes

## 3. Verification

- [x] 3.1 Test notification displays actual message content (not generic "Permission required")
