## 1. Package Setup

- [x] 1.1 Create `package.json` with `@suj1e/cckit` name, bin field, and files whitelist
- [x] 1.2 Create `.npmignore` to exclude `.git`, `openspec/`, `.claude/`, and legacy shell scripts

## 2. CLI Implementation

- [x] 2.1 Create `bin/cli.js` entry point with command routing (install/uninstall/list/update/info)
- [x] 2.2 Implement `install` command: marketplace registration + plugin install loop
- [x] 2.3 Implement `uninstall` command: plugin uninstall + optional marketplace removal
- [x] 2.4 Implement `list` command: read known_marketplaces and plugin caches, display status
- [x] 2.5 Implement `update` command: wrap `claude plugin update <name>@cckit`
- [x] 2.6 Implement `info` command: display plugin metadata from marketplace.json or plugin.json
- [x] 2.7 Add error handling: claude CLI not found, permission errors, network issues

## 3. Cleanup

- [x] 3.1 Delete `install.sh`, `install.ps1`, `install.bat`
- [x] 3.2 Delete `uninstall.sh`, `uninstall.ps1`
- [x] 3.3 Add `node_modules/` to `.gitignore`

## 4. Documentation

- [x] 4.1 Update `README.md` with npm/npx installation instructions and CLI usage reference
- [x] 4.2 Update `CLAUDE.md` to remove shell script references, add npm/npx commands

## 5. CI/CD Pipeline

- [x] 5.1 Create `.github/workflows/publish.yml` — trigger on `v*` tag, checkout, setup node, `npm publish --access public`
- [ ] 5.2 Add NPM_TOKEN to GitHub repository secrets (manual — user action required)

## 6. Verification

- [x] 6.1 Test `node bin/cli.js install barnhk` locally
- [x] 6.2 Test `node bin/cli.js list` shows installed plugins
- [x] 6.3 Test `node bin/cli.js uninstall barnhk` removes plugin
- [x] 6.4 Test `node bin/cli.js install` installs all four plugins
- [x] 6.5 Test `npm pack` to verify package contents match files whitelist
- [x] 6.6 Verify barnhk hook still works after npm-based install (trigger a blocked command)
