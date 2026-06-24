const axios = require('axios');

async function testFetch() {
  try {
    const res = await axios.get('http://localhost:3000/api/v1/properties');
    console.log(JSON.stringify(res.data.data[0], null, 2));
  } catch (err) {
    console.error('Error:', err.message);
  }
}

testFetch();
