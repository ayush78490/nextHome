-- SQL script to create the properties table in Supabase
-- Make sure to run this in the Supabase SQL Editor

CREATE TABLE properties (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    landlord_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    client_first_name VARCHAR(100),
    client_last_name VARCHAR(100),
    client_email VARCHAR(255),
    client_phone VARCHAR(50),
    client_city VARCHAR(100),
    property_type VARCHAR(50) NOT NULL,
    listing_type VARCHAR(50) NOT NULL,
    price DECIMAL(15, 2) NOT NULL,
    description TEXT,
    country VARCHAR(100),
    state VARCHAR(100),
    city VARCHAR(100),
    address TEXT NOT NULL,
    zip_code VARCHAR(20),
    land_sqft INT DEFAULT 0,
    construction_sqft INT DEFAULT 0,
    bedrooms INT DEFAULT 0,
    bathrooms INT DEFAULT 0,
    parking_lots INT DEFAULT 0,
    kitchen INT DEFAULT 0,
    images TEXT[] DEFAULT '{}',
    facilities TEXT[] DEFAULT '{}',
    locality VARCHAR(255),
    is_approved BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- Enable RLS (Row Level Security) if necessary
-- ALTER TABLE properties ENABLE ROW LEVEL SECURITY;

-- Allow public read access to properties (or only approved ones)
-- CREATE POLICY "Public can view properties" ON properties FOR SELECT USING (true);

-- Allow landlords to insert properties
-- CREATE POLICY "Landlords can create properties" ON properties FOR INSERT WITH CHECK (auth.uid() = landlord_id);
