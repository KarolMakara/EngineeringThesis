import http from 'k6/http';

export const options = {
  vus: "1000",
  duration: "120s",
};

export default function () {
    const timestamp = new Date().toISOString();

    const res = http.get('http://74.248.110.218/echo');

    const hostnameMatch = res.body.match(/Hostname:\s*(\S+)/);
    const hostname = hostnameMatch ? hostnameMatch[1] : 'Hostname not found';

    console.log(`[${timestamp}] Hostname: ${hostname}`);
}
