## 1. Configuration

- [x] 1.1 Add `NOTIFICATION_PERMISSION_PROMPT` config option to `barnhk.conf` (default: `skip`)
- [x] 1.2 Add `NOTIFICATION_QUESTION` config option to `barnhk.conf` (default: `transcript`)
- [x] 1.3 Add `NOTIFICATION_IDLE_PROMPT` config option to `barnhk.conf` (default: `transcript`)

## 2. Transcript Extraction

- [x] 2.1 Add `extract_transcript_content` function to `common.sh` that reads transcript file
- [x] 2.2 Implement sessionId validation in extraction function
- [x] 2.3 Implement assistant text extraction logic (read last 30 lines, find type="assistant" with text content)
- [x] 2.4 Add content truncation (200 chars) and fallback to generic message

## 3. Notification Processing

- [x] 3.1 Add `get_notification_mode` helper function to determine mode from config
- [x] 3.2 Modify `notification.sh` to skip sending when mode is `skip`
- [x] 3.3 Modify `notification.sh` to extract transcript content when mode is `transcript`
- [x] 3.4 Ensure fallback to generic message when extraction fails

## 4. Testing & Deployment

- [x] 4.1 Test with `notification_type: "permission_prompt"` - verify no notification sent
- [x] 4.2 Test with `notification_type: "question"` - verify transcript content extracted
- [x] 4.3 Test fallback behavior when transcript extraction fails
- [x] 4.4 Reinstall barnhk plugin to apply changes
