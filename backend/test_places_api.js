const https = require('https');

const data = JSON.stringify({
  input: 'india',
  includedPrimaryTypes: ['country']
});

const options = {
  hostname: 'places.googleapis.com',
  port: 443,
  path: '/v1/places:autocomplete',
  method: 'POST',
  headers: {
    'X-Goog-Api-Key': 'AIzaSyBSU4LGpOsZu7KdPQ-b9e1Vg4u2ij9fquI',
    'Content-Type': 'application/json',
    'Content-Length': data.length
  }
};

const req = https.request(options, (res) => {
  let body = '';
  res.on('data', (chunk) => {
    body += chunk;
  });
  res.on('end', () => {
    console.log(`Status: ${res.statusCode}`);
    console.log(`Response: ${body}`);
  });
});

req.on('error', (error) => {
  console.error(error);
});

req.write(data);
req.end();
