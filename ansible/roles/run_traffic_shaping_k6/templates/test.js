import http from 'k6/http';

export const options = {
  vus: "10000",
  duration: "120s",
};
export default function () {
    const res = http.get('http://74.248.80.11/echo');
    const hostnameMatch = res.body.match(/Hostname:\s*(\S+)/);
    const hostname = hostnameMatch ? hostnameMatch[1] : 'Hostname not found';

    console.log(`Hostname: ${hostname}`);
}