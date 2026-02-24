## Context

barnhk hooks currently have a flat directory structure with all files at the root level. The install script appends hooks without checking for existing ones, causing duplicates on repeated runs. The uninstall script uses exact path matching which may fail if paths change.

## Goals / Non-Goals

**Goals:**
- Clean directory structure with lib/ subdirectory for implementation files
- Idempotent installation (safe to run multiple times)
- Reliable uninstall that cleans up all barnhk hooks

**Non-Goals:**
- Global vs local installation options
- Changes to hook functionality
- Migration script for existing users

## Decisions

### D1: Directory Structure
**Decision:** Use `lib/` subdirectory for implementation files
**Rationale:** Clear separation between user-facing entry points (install.sh, uninstall.sh, README.md) and implementation details

```
hooks/barnhk/
├── README.md
├── install.sh
├── uninstall.sh
└── lib/
    ├── barnhk.conf
    ├── common.sh
    ├── pre-tool-use.sh
    ├── permission-request.sh
    └── task-completed.sh
```

### D2: Idempotent Installation
**Decision:** Run uninstall logic before install to remove existing hooks
**Rationale:** Simple and reliable - ensures clean state before adding hooks. Alternative of checking and skipping duplicates is more complex and error-prone.

### D3: Uninstall by Path Pattern
**Decision:** Match hooks by path containing "barnhk" instead of exact path
**Rationale:** More robust - handles cases where script directory was moved or symlinked

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| Users need to re-run install.sh after update | Document in README |
| Path pattern matching too broad | Use specific pattern `barnhk/lib/` to avoid false positives |

## Migration Plan

1. Move files to new structure
2. Update install.sh and uninstall.sh with new paths and idempotent logic
3. Update common.sh to source from correct relative path
4. User re-runs install.sh to update hooks configuration
