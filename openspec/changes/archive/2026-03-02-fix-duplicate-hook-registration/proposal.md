## Why

barnhk hooks are registered twice, causing duplicate notifications:

1. **settings.json** - hooks merged by `install.sh` merge_hooks() function
2. **plugin.json** - hooks loaded via `enabledPlugins`

Both point to the same scripts, causing 2 notifications for same event.

## What Changes

- Remove `merge_hooks()` function from `install.sh`
- Let plugin.json handle all hook definitions
- Keep `enabledPlugins` management
- **Fix idle_prompt transcript extraction** - notifications show generic content instead of extracting from transcript

## Capabilities

### Modified Capabilities

(none - this is a code change)

## Impact

**install.sh**:
- Remove `merge_hooks()` function and- Simplify installation flow
