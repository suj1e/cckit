#!/bin/bash
set -e

# Default configuration
TARGET_URL=${TARGET_URL:-http://localhost:{{APP_PORT}}}
CONTEXT_PATH=${CONTEXT_PATH:-{{SERVICE_PACKAGE}}}
SCENARIO=${SCENARIO:-smoke}
VUS=${VUS:-10}
DURATION=${DURATION:-30s}
OUT_DIR=${OUT_DIR:-./reports}

usage() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -u, --url URL            Target URL (default: http://localhost:{{APP_PORT}})"
    echo "  -c, --context PATH       Context path (default: {{SERVICE_PACKAGE}})"
    echo "  -s, --scenario SCENARIO  Test scenario: smoke|load|stress|spike|soak|custom"
    echo "  -v, --vus VUS            Virtual users (for custom scenario)"
    echo "  -d, --duration DURATION  Duration (for custom scenario)"
    echo "  -h, --help               Show help"
    echo ""
    echo "Scenarios:"
    echo "  smoke  - Smoke test (10 VUs, 30s)"
    echo "  load   - Load test (10→100 VUs, 10min)"
    echo "  stress - Stress test (10→500 VUs, 15min)"
    echo "  spike  - Spike test (10→1000→10 VUs, 5min)"
    echo "  soak   - Soak test (100 VUs, 1hour)"
    echo "  custom - Custom test (use -v and -d)"
    exit 0
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -u|--url) TARGET_URL="$2"; shift 2 ;;
        -c|--context) CONTEXT_PATH="$2"; shift 2 ;;
        -s|--scenario) SCENARIO="$2"; shift 2 ;;
        -v|--vus) VUS="$2"; shift 2 ;;
        -d|--duration) DURATION="$2"; shift 2 ;;
        -h|--help) usage ;;
        *) echo "Unknown option: $1"; usage ;;
    esac
done

# Check k6
if ! command -v k6 &> /dev/null; then
    echo "Error: k6 not installed"
    echo "Install: brew install k6"
    exit 1
fi

# Create report directory
mkdir -p "$OUT_DIR"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
REPORT_FILE="$OUT_DIR/k6_${SCENARIO}_${TIMESTAMP}.json"

# Scenario configuration
case "$SCENARIO" in
    smoke)
        K6_OPTIONS="--stage 10s:10 --stage 20s:10"
        ;;
    load)
        K6_OPTIONS="--stage 2m:10 --stage 5m:50 --stage 5m:100 --stage 2m:0"
        ;;
    stress)
        K6_OPTIONS="--stage 2m:10 --stage 3m:50 --stage 5m:100 --stage 5m:200 --stage 5m:300 --stage 5m:500 --stage 2m:0"
        ;;
    spike)
        K6_OPTIONS="--stage 10s:10 --stage 30s:1000 --stage 1m:10 --stage 30s:0"
        ;;
    soak)
        K6_OPTIONS="--stage 5m:100 --stage 50m:100 --stage 5m:0"
        ;;
    custom)
        K6_OPTIONS="--stage 10s:$VUS --stage ${DURATION}:$VUS --stage 10s:0"
        ;;
    *)
        echo "Unknown scenario: $SCENARIO"
        exit 1
        ;;
esac

echo "=========================================="
echo "{{SERVICE_NAME}} Performance Test"
echo "Target: $TARGET_URL/$CONTEXT_PATH"
echo "Scenario: $SCENARIO"
echo "=========================================="

# Run test
k6 run \
  --out json="$REPORT_FILE" \
  $K6_OPTIONS \
  -e BASE_URL="$TARGET_URL" \
  -e CONTEXT_PATH="$CONTEXT_PATH" \
  "$(dirname "$0")/load-test.js"

echo ""
echo "Test completed!"
echo "Report: $REPORT_FILE"
