require('dotenv').config();
const propertiesRepository = require('./src/features/properties/properties.repository');
const { supabase } = require('./src/config/supabase');

async function run() {
  try {
    const { data: users } = await supabase.from('users').select('id').limit(1);
    if (!users || users.length === 0) {
      console.log('No users found in DB');
      return;
    }
    const userId = users[0].id;
    console.log('Using userId:', userId);

    const propertyData = {
      landlord_id: userId,
      client_first_name: 'John',
      client_last_name: 'Doe',
      client_email: 'john@example.com',
      client_phone: '1234567890',
      client_city: 'New York',
      title: 'Beautiful Apartment',
      property_type: 'Apartment',
      listing_type: 'Rent',
      price: 1500,
      description: 'A very nice apartment.',
      country: 'USA',
      state: 'NY',
      city: 'New York',
      address: '123 Main St',
      zip_code: '10001',
      land_sqft: 1000,
      construction_sqft: 800,
      bedrooms: 2,
      bathrooms: 1,
      parking_lots: 1,
      kitchen: 1,
      facilities: ['WiFi', 'Pool'],
      locality: 'Downtown - 5km'
    };
    
    const result = await propertiesRepository.create(propertyData);
    console.log('Success:', result.id);
  } catch (err) {
    console.error('Error:', err);
  }
}

run();
