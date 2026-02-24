import http from 'k6/http';
import { check, sleep } from 'k6';

// Configuration from environment
const BASE_URL = __ENV.BASE_URL || 'http://localhost:{{APP_PORT}}';
const CONTEXT_PATH = __ENV.CONTEXT_PATH || '{{SERVICE_PACKAGE}}';

// Build URL
const getUrl = (path) => `${BASE_URL}/${CONTEXT_PATH}${path}`;

// Test endpoints
const endpoints = [
  { path: '/actuator/health', method: 'GET', name: 'Health Check' },
  { path: '/v1/ping', method: 'GET', name: 'Ping' },
];

// Default test function
export default function () {
  const endpoint = endpoints[Math.floor(Math.random() * endpoints.length)];
  const url = getUrl(endpoint.path);

  const res = http.request(endpoint.method, url, null, {
    tags: { name: endpoint.name },
  });

  check(res, {
    [`${endpoint.name}: status < 500`]: (r) => r.status < 500,
    [`${endpoint.name}: latency < 200ms`]: (r) => r.timings.duration < 200,
    [`${endpoint.name}: latency < 500ms`]: (r) => r.timings.duration < 500,
  });

  sleep(Math.random() * 2 + 1);
}

// Setup
export function setup() {
  console.log(`Starting test: ${BASE_URL}/${CONTEXT_PATH}`);

  const healthRes = http.get(getUrl('/actuator/health'));
  if (healthRes.status !== 200) {
    throw new Error(`Service unavailable: ${BASE_URL}`);
  }

  console.log('Service health check passed');
}

// Teardown
export function teardown() {
  console.log('Test completed');
}

// Thresholds
export const options = {
  thresholds: {
    http_req_duration: ['p(95)<500'],
    http_req_failed: ['rate<0.05'],
  },
};
