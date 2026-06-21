const https = require('https');
https.get('https://nexthome1173.s3.amazonaws.com', (res) => {
  console.log('Region:', res.headers['x-amz-bucket-region']);
}).on('error', (e) => {
  console.error(e);
});
