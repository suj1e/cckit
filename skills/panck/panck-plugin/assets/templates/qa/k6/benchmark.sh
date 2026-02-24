#!/bin/bash
# Quick benchmark using wrk, hey, or ab

TARGET_URL=${TARGET_URL:-http://localhost:{{APP_PORT}}/{{SERVICE_PACKAGE}}/actuator/health}
DURATION=${DURATION:-30s}
THREADS=${THREADS:-4}
CONNECTIONS=${CONNECTIONS:-100}

echo "=========================================="
echo "{{SERVICE_NAME}} Quick Benchmark"
echo "Target: $TARGET_URL"
echo "=========================================="

if command -v wrk &> /dev/null; then
    echo "Using wrk..."
    wrk -t$THREADS -c$CONNECTIONS -d$DURATION "$TARGET_URL"
elif command -v hey &> /dev/null; then
    echo "Using hey..."
    hey -n 10000 -c $CONNECTIONS "$TARGET_URL"
elif command -v ab &> /dev/null; then
    echo "Using ab..."
    ab -n 10000 -c $CONNECTIONS "$TARGET_URL"
else
    echo "No benchmark tool found. Install one of:"
    echo "  brew install wrk"
    echo "  brew install hey"
    echo "  brew install ab"
    exit 1
fi
