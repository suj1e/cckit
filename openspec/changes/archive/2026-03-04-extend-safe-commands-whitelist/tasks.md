# Implementation Tasks

## 1. Update is_safe_command() in common.sh

- [x] 1.1 Replace openspec partial list with wildcard: `^openspec[[:space:]]+`
- [x] 1.2 Add directory operations: `mkdir`
- [x] 1.3 Add file operations: `touch`, `cp`, `mv`
- [x] 1.4 Add Docker read-only: `ps`, `ls`, `images`, `logs`, `inspect`, `stats`, `top`, `port`, `exec`
- [x] 1.5 Add Docker resource list: `docker network ls`, `docker volume ls`
- [x] 1.6 Add docker-compose: `up`, `down`, `logs`, `ps`, `build`, `config`

## 2. Add workflow rule to CLAUDE.md

- [x] 2.1 Add "Before git push" workflow section instructing Claude to update docs before push

## 3. Add project directory auto-approve toggle

- [x] 3.1 Add config option `AUTO_APPROVE_PROJECT_COMMANDS=true` to barnhk.conf
- [x] 3.2 Update `is_safe_command()` to check project directory when toggle is enabled
- [x] 3.3 Add documentation for the toggle feature

## 4. Test and verify

- [x] 4.1 Reinstall barnhk plugin
- [x] 4.2 Test openspec commands are auto-approved
- [x] 4.3 Test mkdir/touch/cp/mv are auto-approved
- [x] 4.4 Test docker ps/images/logs are auto-approved
- [x] 4.5 Verify docker rm/rmi still require approval (design: not in whitelist, will require approval)
- [x] 4.6 Test project directory auto-approve toggle works
