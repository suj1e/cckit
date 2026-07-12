## 1. Remove Plugin Source

- [x] 1.1 Delete `skills/jbrick/` directory
- [x] 1.2 Delete `skills/just-task/` directory

## 2. Update Configuration and CLI

- [x] 2.1 Remove jbrick and just-task entries from `.claude-plugin/marketplace.json`
- [x] 2.2 Remove jbrick and just-task from `ALL_PLUGINS` array in `bin/cli.js`
- [x] 2.3 Remove jbrick and just-task descriptions from install success message in `bin/cli.js`

## 3. Update Documentation

- [x] 3.1 Remove jbrick and just-task references from `README.md`
- [x] 3.2 Remove jbrick and just-task sections from `CLAUDE.md`
- [x] 3.3 Remove jbrick references from `standards/plugins/claude-code-plugins.md`

## 4. Verify

- [x] 4.1 Test `node bin/cli.js list` shows only barnhk and review-merge-sync
- [x] 4.2 Test `node bin/cli.js install` installs only remaining plugins
- [x] 4.3 Test `npm pack --dry-run` to verify deleted dirs are excluded
