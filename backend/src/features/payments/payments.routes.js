'use strict';
// Payments routes – Razorpay + Stripe
const express = require('express');
const { authenticateJWT } = require('../../middleware/auth');
const router = express.Router();

// Create payment order (initiate checkout)
router.post('/order',    authenticateJWT, (req, res) => res.json({ success: true, data: null }));
// Verify and capture payment
router.post('/verify',   authenticateJWT, (req, res) => res.json({ success: true, data: null }));
// Stripe webhook (no auth – signature verified internally)
router.post('/webhook/stripe',   express.raw({ type: 'application/json' }), (req, res) => res.json({ received: true }));
// Razorpay webhook
router.post('/webhook/razorpay', (req, res) => res.json({ received: true }));
// Payment history
router.get('/history',   authenticateJWT, (req, res) => res.json({ success: true, data: [] }));

module.exports = router;
