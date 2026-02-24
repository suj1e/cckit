# cckit

Claude Code Kit - A collection of Claude Code extensions (skills and hooks).

## Contents

### Skills

| Skill | Description |
|-------|-------------|
| [panck](./skills/panck) | Spring Boot microservice scaffold generator with DDD/Clean Architecture patterns |

### Hooks

| Hook | Description |
|------|-------------|
| [barnhk](./hooks/barnhk) | Safety and notification hooks with dangerous command protection, auto-approval, and Bark push notifications |

## Installation

Each skill/hook has its own installation script:

```bash
# Install panck skill
cd skills/panck && ./install.sh

# Install barnhk hooks
cd hooks/barnhk && ./install.sh
```

## License

MIT
