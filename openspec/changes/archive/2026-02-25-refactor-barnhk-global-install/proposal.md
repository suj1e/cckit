## Why

Current installation modifies `~/.claude/settings.json` with absolute paths to the project directory. This has problems:
- Config file (`barnhk.conf`) is in project repo - easy to accidentally commit secrets
- Moving project directory breaks hooks
- Each project needs its own install

## What Changes

- Install hooks to `~/.claude/hooks/barnhk/` global directory
- Copy all lib/ files to global location during install
- Config file lives in global directory, safe to edit locally
- Project repo only contains source files for distribution

## Capabilities

### New Capabilities

(None)

### Modified Capabilities

- `safe-command-auto-approval`: Installation now copies files to global `~/.claude/hooks/barnhk/` directory

## Impact

- `install.sh` - copy files to `~/.claude/hooks/barnhk/lib/`, update paths in settings.json
- `uninstall.sh` - remove from global directory
- `lib/barnhk.conf` - becomes a template, actual config is in `~/.claude/hooks/barnhk/lib/`
- Users can freely edit `~/.claude/hooks/barnhk/lib/barnhk.conf` without affecting repo
