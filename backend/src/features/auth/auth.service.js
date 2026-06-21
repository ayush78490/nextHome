'use strict';

const authRepository           = require('./auth.repository');
const { verifyGoogleToken }  = require('../../config/googleAuth');
const { signJWT }              = require('../../middleware/auth');
const { AppError }             = require('../../middleware/errorHandler');
const { cacheDel }             = require('../../config/redis');
const logger                   = require('../../config/logger');
const bcrypt                   = require('bcryptjs');

class AuthService {
  /**
   * Register or sign in a user via Google ID token.
   * Creates user record if first-time sign-in.
   */
  async loginWithGoogle(idToken, email, fcmToken = null) {
    // 1. Verify token with Google
    let decoded;
    try {
      decoded = await verifyGoogleToken(idToken, email);
    } catch (err) {
      throw new AppError('Invalid Google ID token', 401, 'INVALID_TOKEN');
    }

    // 2. Check if user already exists
    let user = await authRepository.findByFirebaseUid(decoded.uid);

    if (!user) {
      // 3. First login – create user record
      logger.info(`New user registration: ${decoded.email}`);
      user = await authRepository.create({
        firebaseUid: decoded.uid,
        email:       decoded.email,
        phone:       decoded.phone_number || null,
        fullName:    decoded.name || decoded.email.split('@')[0],
        avatarUrl:   decoded.picture || null,
        role:        'tenant'
      });
    }

    if (!user.is_active) {
      throw new AppError('Your account is deactivated. Contact support.', 403, 'ACCOUNT_DISABLED');
    }

    // 4. Update FCM token if provided
    if (fcmToken) {
      await authRepository.updateFcmToken(user.id, fcmToken);
    }

    // 5. Issue backend JWT
    const jwt = signJWT({ id: user.id, email: user.email, role: user.role });

    return { user: this._formatUser(user), token: jwt };
  }

  /**
   * Register a new user with email and password
   */
  async registerWithEmail(email, password, fullName) {
    let user = await authRepository.findByEmail(email);
    if (user) {
      throw new AppError('Email already in use', 400, 'USER_EXISTS');
    }

    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(password, salt);

    user = await authRepository.create({
      email,
      passwordHash,
      fullName: fullName || email.split('@')[0],
      role: 'tenant'
    });

    const jwt = signJWT({ id: user.id, email: user.email, role: user.role });
    return { user: this._formatUser(user), token: jwt };
  }

  /**
   * Login with email and password
   */
  async loginWithEmail(email, password) {
    const user = await authRepository.findByEmail(email);
    if (!user) {
      throw new AppError('Invalid email or password', 401, 'INVALID_CREDENTIALS');
    }

    if (!user.password_hash) {
      throw new AppError('This account uses Google Sign-In. Please sign in with Google.', 401, 'INVALID_CREDENTIALS');
    }

    const isMatch = await bcrypt.compare(password, user.password_hash);
    if (!isMatch) {
      throw new AppError('Invalid email or password', 401, 'INVALID_CREDENTIALS');
    }

    if (!user.is_active) {
      throw new AppError('Your account is deactivated. Contact support.', 403, 'ACCOUNT_DISABLED');
    }

    const jwt = signJWT({ id: user.id, email: user.email, role: user.role });
    return { user: this._formatUser(user), token: jwt };
  }

  /**
   * Get the current user's profile
   */
  async getProfile(userId) {
    const user = await authRepository.findById(userId);
    if (!user) throw new AppError('User not found', 404, 'NOT_FOUND');
    return this._formatUser(user);
  }

  /**
   * Update user profile
   */
  async updateProfile(userId, profileData) {
    const user = await authRepository.findById(userId);
    if (!user) throw new AppError('User not found', 404, 'NOT_FOUND');

    const updated = await authRepository.updateProfile(userId, profileData);
    await cacheDel(`user:db:${userId}`);
    return this._formatUser(updated);
  }

  /** Format Supabase (lowercase) keys to camelCase */
  _formatUser(user) {
    let email = user.email;
    let username = null;
    if (email && email.endsWith('@nexthome.local')) {
      username = email.split('@')[0];
      email = null;
    }
    return {
      id:          user.id,
      email:       email,
      username:    username,
      phone:       user.phone,
      fullName:    user.full_name,
      avatarUrl:   user.avatar_url,
      role:        user.role,
      isVerified:  Boolean(user.is_verified),
      createdAt:   user.created_at
    };
  }
}

module.exports = new AuthService();
