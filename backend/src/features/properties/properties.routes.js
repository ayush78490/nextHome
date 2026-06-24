'use strict';
const express = require('express');
const { authenticateJWT, requireRole } = require('../../middleware/auth');
const { upload, uploadToS3 }  = require('../../utils/upload');
const propertiesController = require('./properties.controller');
const propertiesService = require('./properties.service');
const router  = express.Router();

// GET /api/v1/properties – list all properties
router.get('/', propertiesController.listProperties.bind(propertiesController));
// GET /api/v1/properties/:id – get single property
router.get('/:id', propertiesController.getProperty.bind(propertiesController));

// POST /api/v1/properties
router.post('/', authenticateJWT, propertiesController.createProperty.bind(propertiesController));
// PATCH /api/v1/properties/:id
router.patch('/:id', authenticateJWT, requireRole('landlord','admin'), propertiesController.updateProperty.bind(propertiesController));
// DELETE /api/v1/properties/:id
router.delete('/:id', authenticateJWT, requireRole('landlord','admin'), (req, res) => res.json({ success: true }));

// PATCH /api/v1/properties/:id/approve
router.patch('/:id/approve', authenticateJWT, requireRole('admin'), propertiesController.approveProperty.bind(propertiesController));
// PATCH /api/v1/properties/:id/reject
router.patch('/:id/reject', authenticateJWT, requireRole('admin'), propertiesController.rejectProperty.bind(propertiesController));

// POST /api/v1/properties/:id/save – tenant wishlist
router.post('/:id/save', authenticateJWT, (req, res) => res.json({ success: true }));

// POST /api/v1/properties/:id/images - Upload property images
router.post('/:id/images', authenticateJWT, upload.array('images', 10), async (req, res, next) => {
  try {
    if (!req.files || req.files.length === 0) {
      return res.status(400).json({ success: false, message: 'No images provided' });
    }

    const uploadPromises = req.files.map(file => 
      uploadToS3(file.buffer, file.mimetype, 'properties')
    );
    
    const imageUrls = await Promise.all(uploadPromises);
    
    const updatedProperty = await propertiesService.addImages(req.params.id, imageUrls);
    
    res.status(200).json({ success: true, data: updatedProperty });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
