import http from 'k6/http';

export const options = {
  vus: "100000",
  duration: "120s",
};
export default function () {
    const res = http.get('http://172.18.0.50/echo');
    const hostnameMatch = res.body.match(/Hostname:\s*(\S+)/);
    const hostname = hostnameMatch ? hostnameMatch[1] : 'Hostname not found';

    console.log(`Hostname: ${hostname}`);
}