'use strict';

const express        = require('express');
const authController = require('./auth.controller');
const { authenticateJWT } = require('../../middleware/auth');
const { authRateLimiter }      = require('../../middleware/rateLimiter');
const { upload }               = require('../../utils/upload');

const router = express.Router();

// POST /api/v1/auth/login  – Firebase token exchange
router.post('/login', authRateLimiter, authController.login.bind(authController));

// POST /api/v1/auth/register - Email registration
router.post('/register', authRateLimiter, authController.registerEmail.bind(authController));

// POST /api/v1/auth/login/email - Email login
router.post('/login/email', authRateLimiter, authController.loginEmail.bind(authController));

// GET  /api/v1/auth/me  – Get current user profile
router.get('/me', authenticateJWT, authController.getMe.bind(authController));

// PATCH /api/v1/auth/me  – Update profile
router.patch('/me', authenticateJWT, authController.updateMe.bind(authController));

// POST /api/v1/auth/me/avatar  – Upload profile avatar
router.post('/me/avatar', authenticateJWT, upload.single('avatar'), authController.uploadAvatar.bind(authController));

module.exports = router;
