'use strict';
// Chat REST routes (history, rooms)
const express = require('express');
const { authenticateJWT } = require('../../middleware/auth');
const router = express.Router();

router.get('/rooms',         authenticateJWT, (req, res) => res.json({ success: true, data: [] }));
router.post('/rooms',        authenticateJWT, (req, res) => res.json({ success: true, data: null }));
router.get('/rooms/:roomId/messages', authenticateJWT, (req, res) => res.json({ success: true, data: [] }));
router.patch('/messages/:messageId/read', authenticateJWT, (req, res) => res.json({ success: true }));

module.exports = router;
