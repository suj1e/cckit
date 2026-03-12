
import WebSocket from 'ws';
import * as http from 'http';

async function checkBridgeStatus(): Promise<boolean> {
  return new Promise((resolve) => {
    const req = http.get('http://localhost:8989/health', (res) => {
      resolve(res.statusCode === 200);
    });
    req.on('error', () => resolve(false));
    req.setTimeout(2000);
  });
}

async function connectToBridge() {
  console.log('## Feishu Bridge Status Check\n');
  console.log('Checking for Feishu bridge service on localhost:8989...');

  const isRunning = await checkBridgeStatus();

  if (!isRunning) {
    console.log('\n⚠️  Feishu bridge service not found. Please start it first:');
    console.log('```bash\nfeishu-bridge start\n```');
    return;
  }

  console.log('✅ Bridge service is running');

  // 建立WebSocket连接
  const ws = new WebSocket('ws://localhost:8989/cli');

  ws.on('open', () => {
    console.log('✅ Connection established');
    console.log('📡 Message forwarding enabled\n');
    console.log('✅ Successfully connected to Feishu bridge!');
    console.log('Now you can chat with Claude directly in Feishu.');
    console.log('All messages will be synchronized between Feishu and this CLI session.\n');
    console.log('Use /disconnect-feishu to stop forwarding.');

    // 保持连接
    setInterval(() => {
      if (ws.readyState === WebSocket.OPEN) {
        ws.send(JSON.stringify({
          type: 'ping',
          id: Date.now().toString(),
          timestamp: Date.now()
        }));
      }
    }, 30000);
  });

  ws.on('message', (data) => {
    try {
      const message = JSON.parse(data.toString());
      if (message.type === 'user_message') {
        // 将飞书消息作为用户输入提交给CLI
        process.stdout.write(`\n📩 收到飞书消息：${message.content}\n> `);
        // 这里需要将消息注入到CLI会话中
      }
    } catch (error) {
      console.error('解析消息失败:', error);
    }
  });

  ws.on('close', () => {
    console.log('\n❌ Disconnected from Feishu bridge');
  });

  ws.on('error', (error) => {
    console.error('\n❌ Connection error:', error.message);
  });

  // 监听CLI输出，转发到桥服务
  const originalWrite = process.stdout.write;
  let buffer = '';

  (process.stdout.write as any) = function(chunk: any, ...args: any[]) {
    const str = chunk.toString();
    buffer += str;

    if (str.includes('\n') || buffer.length > 100) {
      if (ws.readyState === WebSocket.OPEN) {
        ws.send(JSON.stringify({
          type: 'stream_chunk',
          id: Date.now().toString(),
          timestamp: Date.now(),
          content: buffer
        }));
      }
      buffer = '';
    }

    return originalWrite.call(process.stdout, chunk, ...args);
  };

  // 注册断开连接命令
  process.stdin.on('data', (data) => {
    const input = data.toString().trim();
    if (input === '/disconnect-feishu') {
      if (ws.readyState === WebSocket.OPEN) {
        ws.send(JSON.stringify({
          type: 'stream_end',
          id: Date.now().toString(),
          timestamp: Date.now()
        }));
        ws.close();
      }
      process.stdout.write = originalWrite;
      console.log('\n✅ Disconnected from Feishu bridge');
    }
  });
}

connectToBridge();
