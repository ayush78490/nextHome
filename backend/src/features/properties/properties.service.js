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
    };
    return propertiesRepository.create(propertyData);
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
