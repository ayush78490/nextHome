'use strict';

const propertiesRepository = require('./properties.repository');

class PropertiesService {
  async listProperties(filters = {}) {
    return propertiesRepository.list(filters);
  }

  async getProperty(id) {
    return propertiesRepository.findById(id);
  }

  async createProperty(userId, data) {
    const propertyData = {
      landlord_id: userId,
      client_first_name: data.firstName,
      client_last_name: data.lastName,
      client_email: data.email,
      client_phone: data.phone,
      client_city: data.clientCity,
      title: data.title,
      property_type: data.propertyType,
      listing_type: data.listingType,
      price: data.price,
      description: data.description,
      country: data.country,
      state: data.state,
      city: data.city,
      address: data.address,
      zip_code: data.zipCode,
      land_sqft: data.landSqft || 0,
      construction_sqft: data.constructionSqft || 0,
      bedrooms: data.bedrooms || 0,
      bathrooms: data.bathrooms || 0,
      parking_lots: data.parkingLots || 0,
      kitchen: data.kitchen || 0,
      facilities: data.facilities || [],
      locality: data.locality || '',
    };
    return propertiesRepository.create(propertyData);
  }

  async updateProperty(id, userId, data) {
    const property = await propertiesRepository.findById(id);
    if (!property) throw new Error('Property not found');
    if (property.landlord_id !== userId) throw new Error('Unauthorized');

    const updateData = {};
    if (data.title !== undefined) updateData.title = data.title;
    if (data.price !== undefined) updateData.price = data.price;
    if (data.description !== undefined) updateData.description = data.description;
    if (data.facilities !== undefined) updateData.facilities = data.facilities;
    if (data.locality !== undefined) updateData.locality = data.locality;
    if (data.bedrooms !== undefined) updateData.bedrooms = data.bedrooms;
    if (data.bathrooms !== undefined) updateData.bathrooms = data.bathrooms;
    if (data.landSqft !== undefined) updateData.land_sqft = data.landSqft;
    if (data.constructionSqft !== undefined) updateData.construction_sqft = data.constructionSqft;
    if (data.parkingLots !== undefined) updateData.parking_lots = data.parkingLots;
    if (data.kitchen !== undefined) updateData.kitchen = data.kitchen;
    if (data.propertyType !== undefined) updateData.property_type = data.propertyType;
    if (data.listingType !== undefined) updateData.listing_type = data.listingType;
    if (data.address !== undefined) updateData.address = data.address;
    if (data.city !== undefined) updateData.city = data.city;
    if (data.state !== undefined) updateData.state = data.state;
    if (data.country !== undefined) updateData.country = data.country;
    if (data.zipCode !== undefined) updateData.zip_code = data.zipCode;

    if (data.existingImages !== undefined) {
      updateData.images = data.existingImages;
    }

    return propertiesRepository.update(id, updateData);
  }

  async addImages(id, imageUrls) {
    return propertiesRepository.updateImages(id, imageUrls);
  }

  async approveProperty(id) {
    return propertiesRepository.updateStatus(id, true);
  }

  async rejectProperty(id) {
    return propertiesRepository.delete(id);
  }
}

module.exports = new PropertiesService();
