## Context

Current permission-request.sh only sends notification when auto-approving. Non-whitelisted commands that require user approval have no notification.

## Goals / Non-Goals

**Goals:**
- Notify user when manual approval is needed
- Keep notification optional (respects BARK_SERVER_URL config)

**Non-Goals:**
- Changes to dangerous command handling
- Changes to whitelist logic

## Decisions

### D1: Notification placement
**Decision:** Add notification call before the final `exit 0` for non-whitelisted commands
**Rationale:** Simple one-line addition, consistent with existing auto-approval notification pattern

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| Notification spam for frequent approvals | User can disable by not configuring BARK_SERVER_URL |
