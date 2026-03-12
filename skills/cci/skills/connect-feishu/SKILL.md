---
name: connect-feishu
description: Connect to Feishu bridge for Claude Code integration. Detects existing bridge processes, starts new bridge if needed, and enables bidirectional message forwarding between Feishu and Claude CLI. Trigger with /connect-feishu or phrases like "connect feishu", "start feishu bridge".
license: MIT
compatibility: Requires Feishu bridge service running on localhost:8989.
metadata:
  author: cci
  version: "1.0"
  generatedBy: "1.1.1"
---

# Connect-Feishu - Feishu Bridge Connector

Establish bidirectional message forwarding between Feishu robot and Claude CLI session.

## Quick Start

```
/connect-feishu
```

Or simply say:
```
连接飞书
启动飞书桥接
```

## Core Features

### 1. Bridge Service Detection
- Automatically detect running Feishu bridge service on port 8989
- If service not running, prompt to start it first with `feishu-bridge start`
- Display service status and connection information

### 2. Establish WebSocket Connection
- Connect to bridge service WebSocket endpoint at `ws://localhost:8989/cli`
- Enable bidirectional message forwarding:
  - Feishu messages → Forward to Claude CLI as user input
  - Claude CLI output → Forward to Feishu chat in real-time

### 3. Streaming Response Support
- Support real-time streaming response from Claude CLI to Feishu
- Automatically convert markdown, code blocks, and formatted text to Feishu rich text format

### 4. Disconnect Command
Register `/disconnect-feishu` command for graceful shutdown:
- Close WebSocket connection
- Stop message forwarding
- Restore normal CLI operation

## Workflow

### Step 1: Check Bridge Service Status
First, actually check if Feishu bridge service is running on port 8989:
```bash
lsof -i :8989 || echo "Port 8989 is not in use"
```

Display the actual check result to the user:
```
## Feishu Bridge Status Check

Checking for Feishu bridge service on localhost:8989...
```

**If service is running:**
- Show: "✅ Bridge service is running"
- Continue to connection step

**If service is NOT running:**
- Show: "⚠️ Feishu bridge service not found. Starting bridge service..."
- Start the bridge service in background:
```bash
nohup feishu-bridge start > /var/log/feishu-bridge.log 2>&1 &
sleep 2
```
- Verify service started: repeat the port check command
- If service still not running, show error and exit

### Step 2: Verify Connection
Check bridge health endpoint:
```bash
curl -s http://localhost:8989/health || echo "Health check failed"
```

### Step 3: Connection Confirmation
Display real connection status:
```
✅ Successfully connected to Feishu bridge!
Now you can chat with Claude directly in Feishu.
All messages will be synchronized between Feishu and this CLI session.

**Status:**
- Bridge service: running
- Message forwarding: enabled
- Real-time streaming: active

Use /disconnect-feishu to stop forwarding.
```

### Important Rules
From this moment onward:
1. All messages received from Feishu MUST be processed as user input
2. All your responses MUST be sent to Feishu via the bridge
3. Preserve all markdown formatting, code blocks, and rich text
4. When user sends `/disconnect-feishu`, stop all forwarding immediately

## Related Commands
- `/disconnect-feishu` - Disconnect from Feishu bridge and stop message forwarding
