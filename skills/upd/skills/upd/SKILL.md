---
name: upd
description: Update project documentation based on recent changes. Updates README.md and CLAUDE.md, then commits and pushes. Trigger with /upd or phrases like "update docs", "refresh documentation".
---

# Upd - Update Project Documentation

Analyze recent code changes and update project documentation accordingly.

## Quick Start

```
/upd
```

Or simply say:
```
更新文档
update the docs
```

## Configuration

Set environment variable to control behavior:

- `UPD_TARGET_ALL_MD=false` (default) - Only update README.md and CLAUDE.md
- `UPD_TARGET_ALL_MD=true` - Update all .md files in project

## Workflow

### Step 1: Detect Changes

Analyze recent git activity to understand what changed:

```bash
git status
git log -5 --oneline
git diff HEAD~1 --stat
```

### Step 2: Identify Target Documents

Check which documents exist and should be updated:

**Default mode** (`UPD_TARGET_ALL_MD=false`):
- README.md (if exists)
- CLAUDE.md (if exists)

**Extended mode** (`UPD_TARGET_ALL_MD=true`):
- All .md files in project
- Excludes: node_modules/, .git/, openspec/changes/archive/

### Step 3: Analyze Impact

For each code change, determine documentation impact:

| Code Change | Doc Update |
|-------------|------------|
| New features | Update feature list |
| API changes | Update API documentation |
| Config changes | Update configuration section |
| Dependencies | Update installation/setup section |
| Bug fixes | Optionally update known issues |

### Step 4: Update Documentation

For each target document:
1. Read current content
2. Identify sections that need updates
3. Make accurate updates based on code changes
4. Preserve existing valid content

### Step 5: Commit and Push

If documentation was updated:

```bash
git add README.md CLAUDE.md
git commit -m "docs: update documentation"
git push
```

If no updates needed:
- Notify user: "No documentation updates needed"
- Skip commit and push

## Output Format

```
## Documentation Updated

**Changes detected:**
- feat: add new feature X
- fix: resolve issue Y

**Documents updated:**
- README.md: Added feature X description
- CLAUDE.md: Updated configuration options

**Committed:** docs: update documentation
**Pushed to:** origin/main
```

## Notes

- Only updates documentation based on actual code changes
- Does not generate new documentation from scratch
- Preserves existing content that is still accurate
- Safe to run multiple times
