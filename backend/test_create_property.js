require('dotenv').config();
const propertiesService = require('./src/features/properties/properties.service');

async function run() {
  try {
    const data = {
      firstName: 'John',
      lastName: 'Doe',
      email: 'john@example.com',
      phone: '1234567890',
      clientCity: 'New York',
      title: 'Beautiful Apartment',
      propertyType: 'Apartment',
      listingType: 'Rent',
      price: 1500,
      description: 'A very nice apartment.',
      country: 'USA',
      state: 'NY',
      city: 'New York',
      address: '123 Main St',
      zipCode: '10001',
      landSqft: 1000,
      constructionSqft: 800,
      bedrooms: 2,
      bathrooms: 1,
      parkingLots: 1,
      kitchen: 1,
      facilities: ['WiFi', 'Pool'],
      locality: 'Downtown - 5km'
    };
    // Using a random UUID for landlord_id to see if it fails due to foreign key or something else.
    // We'll see the exact error.
    await propertiesService.createProperty('1f440656-ce05-40c7-b3e7-26cae8b40430', data);
    console.log('Success');
  } catch (err) {
    console.error('Error:', err);
  }
}

run();
