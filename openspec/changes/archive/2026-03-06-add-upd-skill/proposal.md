# Add Upd Skill

## Why

Updating project documentation after making code changes is often forgotten, leading to outdated README.md and CLAUDE.md files. A dedicated `/upd` skill streamlines this workflow by automatically detecting changes and updating documentation with a single command.

## What Changes

- Add new `upd` skill to cckit
- Skill updates README.md and CLAUDE.md based on recent git changes
- Configurable option to update all .md files in project (default: disabled)
- Auto-commits and pushes documentation changes

## Capabilities

### New Capabilities

- `upd-skill`: A skill that analyzes recent code changes and updates project documentation accordingly, with configurable scope and auto-commit/push functionality.

### Modified Capabilities

(none - this is a new skill)

## Impact

**New files:**
- `skills/upd/SKILL.md` - Skill definition and workflow instructions

**Affected systems:**
- cckit plugin marketplace (new skill available)
- Git workflow (auto-commit and push)
