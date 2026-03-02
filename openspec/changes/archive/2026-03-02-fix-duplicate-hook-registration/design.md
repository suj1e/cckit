## Context

Current barnhk plugin uses two hook registration mechanisms:

### settings.json (hooks merged by install.sh)
```json
"hooks": {
  "PermissionRequest": [...],
  "Notification": [...]
}
```

### plugin.json (hooks loaded via enabledPlugins)
```json
"hooks": {
  "PermissionRequest": [...],
  "Notification": [...}
}
```

### enabledPlugins
```json
"enabledPlugins": {
  "barnhk@cckit": true
}
```

## Goals / Non-Goals

**Goals:**
- Remove duplicate hook registration
- Rely solely on plugin.json for hooks

**Non-Goals:**
- Not changing plugin.json hook structure
- Not changing enabledPlugins behavior

## Decisions

### Decision 1: Remove merge_hooks() from install.sh

**Rationale:** The plugin.json already defines hooks, The `enabledPlugins` mechanism handles loading. hooks into settings.json is redundant and causes duplicate execution.

**Alternative:** Keep merge_hooks() but remove enabledPlugins → Rejected because enabledPlugins is needed for plugin discovery and feature, users would have to manually manage hooks in settings.json if giving more control.

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| Users with custom hooks in settings.json | merge_hooks() only removes hooks matching plugin paths, keep documentation for users about the change |
