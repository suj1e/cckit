#!/bin/bash

# Get session name from current directory
SESSION_NAME=$(basename "$PWD")

# Check if session exists
if zellij list-sessions 2>/dev/null | grep -q "^$SESSION_NAME"; then
    zellij attach "$SESSION_NAME"
else
    zellij -s "$SESSION_NAME"
fi
