const https = require('https');

https.get('https://nexthome1173.s3.eu-north-1.amazonaws.com/properties/1f440656-ce05-40c7-b3e7-26cae8b40430.jpeg', (res) => {
  console.log(`Status Code: ${res.statusCode}`);
  let data = '';
  res.on('data', chunk => data += chunk);
  res.on('end', () => console.log(data.substring(0, 200)));
});
