import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  vus: 10,
  duration: '10s',
};

export default function () {
  const url = 'http://172.18.0.2/echo';
  const res = http.get(url);

  check(res, {
    'status is 200': (r) => r.status === 200,
  });

  const hostnameMatch = res.body.match(/Hostname:\s*(\S+)/);
  const hostname = hostnameMatch ? hostnameMatch[1] : 'Hostname not found';

  console.log(`Hostname: ${hostname}`);
  // sleep(0.05)
}
