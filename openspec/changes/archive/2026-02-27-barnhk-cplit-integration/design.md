## Context

barnhk is a Claude CLI hook system that intercepts commands and provides auto-approval for whitelisted commands. For non-whitelisted commands, it currently only sends notifications and requires the user to be at their computer to manually approve.

cplit is a separate service that provides remote approval via Feishu interactive cards. It exposes a `POST /request-approval` endpoint that blocks until the user responds or times out (default 60s).

## Goals / Non-Goals

**Goals:**
- Enable remote approval for non-whitelisted commands when cplit is enabled
- Make the feature opt-in via configuration (default: disabled)
- Graceful fallback when cplit is unavailable

**Non-Goals:**
- Changing the whitelist behavior (whitelisted commands still auto-approve)
- Modifying cplit service (it's a separate project)
- Adding persistence or state management

## Decisions

### 1. Configuration Design

**Decision**: Add two new config options to `barnhk.conf`:
```bash
CPLIT_ENABLED=false   # Master switch, default off
CPLIT_URL=""          # e.g., "https://dmall.ink"
```

**Rationale**: Simple on/off switch with URL config. Default disabled ensures no breaking changes.

### 2. Integration Point

**Decision**: Integrate in `permission-request.sh` after whitelist check fails.

**Flow**:
```
command not in whitelist
    │
    ├── CPLIT_ENABLED=true && CPLIT_URL set
    │       │
    │       ├── Call cplit API (blocking, max 60s)
    │       │       │
    │       │       ├── Response received → output decision JSON
    │       │       └── Timeout/error → fallback to local manual
    │       │
    │       └── Output: allow or deny JSON based on cplit response
    │
    └── CPLIT_ENABLED=false
            │
            └── Send notification only (current behavior)
```

**Rationale**: Minimal changes to existing code, clear separation of concerns.

### 3. API Call Implementation

**Decision**: Use `curl` with timeout to call cplit API.

```bash
# In common.sh
request_cplit_approval() {
    local command="$1"
    local cwd="$2"

    local response
    response=$(curl -s -m 70 -X POST \
        -H "Content-Type: application/json" \
        -d "{\"command\":\"$command\",\"cwd\":\"$cwd\"}" \
        "${CPLIT_URL}/request-approval" 2>/dev/null)

    echo "$response"
}
```

**Rationale**:
- 70s timeout gives cplit's 60s timeout room to respond
- Silent failure (`-s`, `2>/dev/null`) for graceful degradation
- Simple JSON parsing with `jq`

### 4. Decision JSON Output

**Decision**: Output proper Claude CLI hook response format based on cplit decision.

```bash
# approve
{"hookSpecificOutput":{"hookEventName":"PermissionRequest","decision":{"behavior":"allow"}}}

# deny
{"hookSpecificOutput":{"hookEventName":"PermissionRequest","decision":{"behavior":"deny"}}}
```

**Rationale**: Matches the existing auto-approve format, just with different `behavior` value.

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| cplit server unavailable | Fallback to local manual approval (send notification, exit 0) |
| Network latency | 70s curl timeout accounts for cplit's 60s timeout |
| User doesn't respond | cplit auto-approves after timeout (designed behavior) |
| Command injection in JSON | Escape special characters before building JSON payload |
