'use strict';

const authService = require('./auth.service');
const { AppError } = require('../../middleware/errorHandler');

class AuthController {
  /**
   * POST /api/v1/auth/login
   * Body: { idToken: string, fcmToken?: string }
   */
  async login(req, res, next) {
    try {
      const { idToken, email, fcmToken } = req.body;
      if (!idToken) throw new AppError('idToken is required', 400, 'VALIDATION_ERROR');

      const result = await authService.loginWithGoogle(idToken, email, fcmToken);
      res.status(200).json({ success: true, data: result });
    } catch (err) { next(err); }
  }
  /**
   * POST /api/v1/auth/register
   * Body: { email, password, fullName }
   */
  async registerEmail(req, res, next) {
    try {
      let { email, username, password, fullName } = req.body;
      if (!email && username) {
        email = `${username}@nexthome.local`;
      }
      if (!email || !password) throw new AppError('Email or username, and password are required', 400, 'VALIDATION_ERROR');

      const result = await authService.registerWithEmail(email, password, fullName || username);
      res.status(201).json({ success: true, data: result });
    } catch (err) { 
      if (err.message === 'Email already in use' && req.body.username && !req.body.email) {
        err.message = 'Username already in use';
      }
      next(err); 
    }
  }

  /**
   * POST /api/v1/auth/login/email
   * Body: { email, password }
   */
  async loginEmail(req, res, next) {
    try {
      let { email, username, password } = req.body;
      if (!email && username) {
        email = `${username}@nexthome.local`;
      }
      if (!email || !password) throw new AppError('Email or username, and password are required', 400, 'VALIDATION_ERROR');

      const result = await authService.loginWithEmail(email, password);
      res.status(200).json({ success: true, data: result });
    } catch (err) { 
      if (err.message === 'Invalid email or password' && req.body.username && !req.body.email) {
        err.message = 'Invalid username or password';
      }
      next(err); 
    }
  }

  /**
   * GET /api/v1/auth/me
   * Header: Authorization: Bearer <firebase_id_token>
   */
  async getMe(req, res, next) {
    try {
      const profile = await authService.getProfile(req.user.id);
      res.status(200).json({ success: true, data: profile });
    } catch (err) { next(err); }
  }

  /**
   * PATCH /api/v1/auth/me
   * Body: { fullName?, phone?, avatarUrl? }
   */
  async updateMe(req, res, next) {
    try {
      const { fullName, phone, avatarUrl } = req.body;
      const updated = await authService.updateProfile(req.user.id, { fullName, phone, avatarUrl });
      res.status(200).json({ success: true, data: updated });
    } catch (err) { next(err); }
  }

  /**
   * POST /api/v1/auth/me/avatar
   * Request: multipart/form-data with 'avatar' file
   */
  async uploadAvatar(req, res, next) {
    try {
      if (!req.file) {
        throw new AppError('No avatar file provided', 400, 'VALIDATION_ERROR');
      }

      const { uploadToS3 } = require('../../utils/upload');
      const avatarUrl = await uploadToS3(req.file.buffer, req.file.mimetype, 'avatars');
      
      const updated = await authService.updateProfile(req.user.id, { avatarUrl });
      res.status(200).json({ success: true, data: updated });
    } catch (err) { next(err); }
  }
}

module.exports = new AuthController();
