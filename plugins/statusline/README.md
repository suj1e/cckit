# cckit-statusline

Claude Code status line plugin — model, context usage bar, git branch, and session cost in one line.

## What it shows

```
[Opus] 📁 my-project | 🌿 main +2 ~1
▓▓▓▓▓░░░░░░ 35% | $0.45 | ⏱ 12m 30s
```

- **Line 1**: model name, directory, git branch (+ staged, ~ modified)
- **Line 2**: context usage progress bar (color-coded), cost, duration

## Install

```bash
npx @suj1e/cckit install statusline
```

One command. The script is deployed to `~/.claude/cckit/statusline.sh` and `settings.json` is updated automatically.

Or manually:

```bash
claude plugin marketplace add https://github.com/suj1e/cckit
claude plugin install statusline@cckit --scope user
```

Then copy `settings.json` content to `~/.claude/settings.json`.

## Uninstall

```bash
npx @suj1e/cckit uninstall statusline
```

Removes the script and config automatically.

## How it works

- `cckit install statusline` deploys `scripts/statusline.sh` to `~/.claude/cckit/statusline.sh`
- Injects `statusLine` into `~/.claude/settings.json`
- `cckit uninstall statusline` removes both

### Manual setup

If you installed manually, copy `plugins/statusline/settings.json` into `~/.claude/settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/cckit/statusline.sh",
    "padding": 2
  }
}
```

## Trigger events

- After each assistant message
- After `/compact`
- When permission mode changes
- When vim mode toggles

## Performance

Git info is cached per-session with a 5-second TTL to avoid slowing down the status bar.

## Customize

Edit `~/.claude/cckit/statusline.sh` to tweak the output.

## Requirements

- `jq` for JSON parsing
- `git` (optional, for branch info)

## References

- [Claude Code Status Line Docs](https://code.claude.com/docs/en/statusline)
- [cckit Status Line Standard](../../standards/statusline/claude-code-statusline.md)
