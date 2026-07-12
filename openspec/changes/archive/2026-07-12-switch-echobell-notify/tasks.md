## 1. Rewrite notify.sh

- [x] 1.1 Replace all backends with `send_echobell_notification` function
- [x] 1.2 Update `send_notification` to call EchoBell only

## 2. Switch config to .env

- [x] 2.1 Rename `barnhk.conf` → `barnhk.env` with `.env` format
- [x] 2.2 Update `common.sh` to load `barnhk.env`
- [x] 2.3 Remove deprecated config variables (BARK_SERVER_URL, DISCORD_*, FEISHU_*)

## 3. Update tests and docs

- [x] 3.1 Update `test-notify.sh` for EchoBell dry-run
- [x] 3.2 Update `hooks/barnhk/README.md` config section

## 4. Verify

- [x] 4.1 Run all tests
- [x] 4.2 Test `node bin/cli.js install barnhk`
- [x] 4.3 Verify `npm pack` includes `barnhk.env` not `barnhk.conf`
