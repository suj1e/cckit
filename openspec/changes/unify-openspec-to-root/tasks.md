## 1. Analysis

- [x] 1.1 Compare specs between `cckit/openspec/specs/` and `hooks/barnhk/openspec/specs/` to identify duplicates and unique files
- [x] 1.2 Identify active changes in `hooks/barnhk/openspec/changes/` that need migration

## 2. Migration

- [x] 2.1 Migrate unique specs from `hooks/barnhk/openspec/specs/` to `cckit/openspec/specs/`
- [x] 2.2 Migrate active changes from `hooks/barnhk/openspec/changes/` to `cckit/openspec/changes/`
- [x] 2.3 Merge `hooks/barnhk/openspec/specs/archive/` content into `cckit/openspec/specs/archive/` if needed

## 3. Cleanup

- [x] 3.1 Delete `hooks/barnhk/openspec/` directory
- [x] 3.2 Update `CLAUDE.md` to document OpenSpec unified management policy

## 4. Verification

- [x] 4.1 Verify no broken references in documentation
- [x] 4.2 Verify git history preserved for moved files
