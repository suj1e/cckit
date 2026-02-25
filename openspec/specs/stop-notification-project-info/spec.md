## REMOVED Requirements

### Requirement: Stop notification displays project name

**Reason**: Project name now displayed in notification title prefix (see `notification-project-prefix` capability), avoiding duplication in notification body.

**Migration**: Project name is automatically added to title by `send_notification` function. Stop hook no longer needs to add project name to body.

### Requirement: Project name appears first in notification

**Reason**: Project name now displayed in notification title prefix (see `notification-project-prefix` capability).

**Migration**: Project name appears in title as `[project] Claude Stopped` instead of body.
