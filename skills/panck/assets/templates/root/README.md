# {{SERVICE_NAME}}

{{SERVICE_DESCRIPTION}}

## Quick Start

```bash
# Development
./run.sh dev

# Build
./gradlew clean build

# Test
./gradlew test

# Docker
docker build -t nexora/{{SERVICE_NAME}}:latest .
```

## Ports

| Port | Purpose |
|------|---------|
| {{APP_PORT}} | Application |
| {{MGMT_PORT}} | Management/Actuator |

## API

Base URL: `http://localhost:{{APP_PORT}}{{CONTEXT_PATH}}/v1`

## Health Check

```bash
curl http://localhost:{{MGMT_PORT}}/actuator/health
```

## Documentation

See [CLAUDE.md](./CLAUDE.md) for development guidelines.
