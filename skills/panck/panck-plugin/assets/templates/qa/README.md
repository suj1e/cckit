# {{SERVICE_NAME}} QA

Quality assurance test configurations and scripts.

## Directory Structure

```
qa/
├── k6/                      # K6 Performance Testing
│   ├── load-test.js         # Load test script
│   ├── load-test.sh         # Test runner
│   └── benchmark.sh         # Quick benchmark
{{JMH_DIRECTORY}}
```

## Test Scenarios

| Scenario | Description | VUs | Duration |
|----------|-------------|-----|----------|
| smoke | Smoke test | 10 | 30s |
| load | Load test | 10→100 | 10min |
| stress | Stress test | 10→500 | 15min |
| spike | Spike test | 10→1000→10 | 5min |
| soak | Soak test | 100 | 1hour |

## Quick Start

### Install K6

```bash
# macOS
brew install k6

# Linux
sudo apt-get install k6

# Verify
k6 version
```

### Run Tests

```bash
cd qa/k6

# Smoke test
./load-test.sh -s smoke

# Load test
./load-test.sh -s load

# Custom
./load-test.sh -s custom -v 50 -d 5m
```

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| TARGET_URL | http://localhost:{{APP_PORT}} | Target service URL |
| CONTEXT_PATH | {{SERVICE_PACKAGE}} | Context path |

## Performance Targets

| Metric | Target |
|--------|--------|
| P50 Latency | < 50ms |
| P95 Latency | < 200ms |
| P99 Latency | < 500ms |
| Error Rate | < 0.1% |
