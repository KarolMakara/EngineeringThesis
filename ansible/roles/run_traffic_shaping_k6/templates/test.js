import http from 'k6/http';
import { check } from 'k6';

export const options = {
  vus: "1000000",
  duration: "5s",
};

export default function () {
  const url = 'http://172.18.0.50/echo';
  const res = http.get(url);

  check(res, {
    'status is 200': (r) => r.status === 200,
  });

  const hostnameMatch = res.body.match(/Hostname:\s*(\S+)/);
  const hostname = hostnameMatch ? hostnameMatch[1] : 'Hostname not found';

  console.log(`Hostname: ${hostname}`);
}
