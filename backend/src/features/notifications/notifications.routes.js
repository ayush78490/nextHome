'use strict';
// Notifications routes
const express = require('express');
const { authenticateJWT } = require('../../middleware/auth');
const router = express.Router();

router.get('/',         authenticateJWT, (req, res) => res.json({ success: true, data: [] }));
router.patch('/:id/read', authenticateJWT, (req, res) => res.json({ success: true }));
router.patch('/read-all', authenticateJWT, (req, res) => res.json({ success: true }));
router.delete('/:id',  authenticateJWT, (req, res) => res.json({ success: true }));

module.exports = router;
