## Context

cplit sends Feishu interactive cards for command approval. Current layout uses `is_short: true` for all fields, making them squeeze together in rows of 2-3 columns. This looks cramped especially for long commands.

## Goals / Non-Goals

**Goals:**
- Make command text easy to read (full width)
- Add visual icons for quick scanning
- Maintain consistent layout across all card types
- Show directory in result cards for context

**Non-Goals:**
- Not changing card functionality (buttons, callbacks)
- Not adding new fields beyond what's already in request card

## Decisions

### Decision 1: Field layout strategy

**Choice**: Command takes full width, other fields share rows.

```
┌─────────────────────────────────────────┐
│ ⌨️ 命令                                  │
│ `rm -rf build`                          │
├──────────────────┬──────────────────────┤
│ 📁 目录           │ 🔗 请求ID            │
│ `/gateway-center`│ `1234`               │
└──────────────────┴──────────────────────┘
```

**Rationale**: Command is the most critical information that needs full visibility. Directory and request ID are secondary and can share space.

### Decision 2: Icon mapping

| Field | Icon | Purpose |
|-------|------|---------|
| Command | ⌨️ | Indicates terminal/command |
| Directory | 📁 | Indicates folder/path |
| Request ID | 🔗 | Indicates reference/link |
| Time | 🕐 | Indicates timestamp |

### Decision 3: Markdown formatting

**Choice**: Use bold labels with newline separation.

```markdown
**⌨️ 命令**
`rm -rf build`
```

**Rationale**: Clear visual separation between label and value.

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| Long commands might still overflow | Truncate very long commands (>100 chars) with ellipsis |
| Icons might not render on some clients | Use standard Unicode emoji, widely supported |
