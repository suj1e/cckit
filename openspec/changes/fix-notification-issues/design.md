## Context

Two separate notification issues in different codebases:

1. **barnhk (cckit)**: The Notification hook uses a single title (`TITLE_QUESTION`) for all notification types. When `idle_prompt` notifications are sent (Claude waiting for input), they incorrectly show "❓ Claude Question" instead of a more appropriate waiting indicator.

2. **cplit (separate repo)**: The Feishu interactive card for remote approval has incorrect `fields` format. The card shows header and action buttons, but content fields don't render.

## Goals / Non-Goals

**Goals:**
- Fix barnhk to use type-appropriate notification titles
- Fix cplit Feishu card fields to render correctly

**Non-Goals:**
- Not adding new notification types
- Not changing notification content extraction logic (already done in previous change)

## Decisions

### Decision 1: Title selection by notification type (barnhk)

**Choice**: Add a `get_notification_title()` function that maps notification types to title config variables.

**Rationale**: Clean separation of concerns, easy to extend for future notification types.

```
notification_type → title variable
─────────────────────────────────────
question          → TITLE_QUESTION
idle_prompt       → TITLE_IDLE_PROMPT (new)
* (default)       → TITLE_QUESTION
```

**Alternative considered**: Add title parameter to `send_notification()` - rejected because it would require changes across multiple hooks.

### Decision 2: Feishu card fields format (cplit)

**Choice**: Wrap field content in `text` object and add `is_short` property.

**Rationale**: Matches Feishu's official card specification.

```typescript
// Before (incorrect)
fields: [
  { tag: "lark_md", content: "**命令:**\n`cmd`" }
]

// After (correct)
fields: [
  {
    is_short: true,
    text: {
      tag: "lark_md",
      content: "**命令:**\n`cmd`"
    }
  }
]
```

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| Users with custom TITLE_QUESTION expect it for all types | Add TITLE_IDLE_PROMPT with sensible default, allow override |
| Feishu card format may change | Follow official Feishu documentation, use card builder for validation |
