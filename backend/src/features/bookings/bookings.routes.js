'use strict';
// Bookings routes scaffold
const express = require('express');
const { authenticateJWT, requireRole } = require('../../middleware/auth');
const router  = express.Router();

router.get('/',      authenticateJWT, (req, res) => res.json({ success: true, data: [] }));
router.post('/',     authenticateJWT, requireRole('tenant'), (req, res) => res.json({ success: true, data: null }));
router.get('/:id',   authenticateJWT, (req, res) => res.json({ success: true, data: null }));
router.patch('/:id', authenticateJWT, requireRole('landlord','admin'), (req, res) => res.json({ success: true, data: null }));
router.delete('/:id',authenticateJWT, (req, res) => res.json({ success: true }));

module.exports = router;
