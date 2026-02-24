## Context

Current installation directly references project directory paths in settings.json. This couples the hooks to a specific project location.

## Goals / Non-Goals

**Goals:**
- Install hooks to global `~/.claude/hooks/barnhk/` directory
- Config file editable without affecting project repo
- Single global installation works across all projects

**Non-Goals:**
- Per-project configuration
- Changes to hook functionality

## Decisions

### D1: Installation Directory
**Decision:** Use `~/.claude/hooks/barnhk/` as global installation target
**Rationale:** Follows Claude Code's convention of keeping hooks in `.claude/` directory

```
~/.claude/
├── settings.json
└── hooks/
    └── barnhk/
        ├── lib/
        │   ├── barnhk.conf      ← user edits this
        │   ├── common.sh
        │   ├── pre-tool-use.sh
        │   ├── permission-request.sh
        │   └── task-completed.sh
        └── (install.sh stays in project)
```

### D2: Installation Flow
**Decision:** Copy files from project to global directory on each install
**Rationale:**
- Allows updating hooks by running install.sh again
- Preserves user's config by not overwriting barnhk.conf if it exists
- Project repo acts as source of truth for scripts

### D3: Config File Handling
**Decision:** Don't overwrite existing barnhk.conf during install
**Rationale:** Preserves user's BARK_SERVER_URL and other settings

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| User forgets to reinstall after updating source | Document in README |
| Old hooks in different location | install.sh removes old barnhk hooks by path pattern first |
