'use strict';

const propertiesService = require('./properties.service');

class PropertiesController {
  async listProperties(req, res, next) {
    try {
      const properties = await propertiesService.listProperties(req.query);
      res.status(200).json({ success: true, data: properties });
    } catch (err) {
      next(err);
    }
  }

  async getProperty(req, res, next) {
    try {
      const property = await propertiesService.getProperty(req.params.id);
      if (!property) return res.status(404).json({ success: false, message: 'Property not found' });
      res.status(200).json({ success: true, data: property });
    } catch (err) {
      next(err);
    }
  }

  async createProperty(req, res, next) {
    try {
      const property = await propertiesService.createProperty(req.user.id, req.body);
      res.status(201).json({ success: true, data: property });
    } catch (err) {
      next(err);
    }
  }

  async updateProperty(req, res, next) {
    try {
      const property = await propertiesService.updateProperty(req.params.id, req.user.id, req.body);
      res.status(200).json({ success: true, data: property });
    } catch (err) {
      next(err);
    }
  }

  async approveProperty(req, res, next) {
    try {
      await propertiesService.approveProperty(req.params.id);
      res.status(200).json({ success: true, message: 'Property approved' });
    } catch (err) {
      next(err);
    }
  }

  async rejectProperty(req, res, next) {
    try {
      await propertiesService.rejectProperty(req.params.id);
      res.status(200).json({ success: true, message: 'Property rejected' });
    } catch (err) {
      next(err);
    }
  }
}

module.exports = new PropertiesController();
