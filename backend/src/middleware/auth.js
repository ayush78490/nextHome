'use strict';

const jwt                  = require('jsonwebtoken');
const { AppError }         = require('./errorHandler');
const { supabase }         = require('../config/supabase');
const { cacheGet, cacheSet } = require('../config/redis');

/**
 * Verify JWT token issued by our backend (used for socket / session auth)
 */
function verifyJWT(token) {
  return jwt.verify(token, process.env.JWT_SECRET || 'changeme');
}

/**
 * Issue a signed JWT for an authenticated user
 */
function signJWT(payload, expiresIn = '7d') {
  return jwt.sign(payload, process.env.JWT_SECRET || 'changeme', { expiresIn });
}

/**
 * Middleware: authenticate via backend JWT (replaces Firebase)
 * Header: Authorization: Bearer <backend_jwt>
 */
async function authenticateJWT(req, res, next) {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader?.startsWith('Bearer ')) {
      throw new AppError('Authorization token required', 401, 'UNAUTHORIZED');
    }
    const token = authHeader.split('Bearer ')[1];
    const decoded = verifyJWT(token);

    // Fetch (or cache) user record from DB using our backend ID
    const cacheKey = `user:db:${decoded.id}`;
    let user = await cacheGet(cacheKey);
    if (!user) {
      const { data, error } = await supabase
        .from('users')
        .select('id, email, full_name, role, is_active, fcm_token, firebase_uid')
        .eq('id', decoded.id)
        .single();
      
      if (!error && data) {
        user = data;
        await cacheSet(cacheKey, user, 300);
      }
    }

    if (!user) {
      throw new AppError('User not found. Please register first.', 404, 'USER_NOT_FOUND');
    }
    if (!user.is_active) {
      throw new AppError('Your account has been deactivated.', 403, 'ACCOUNT_DISABLED');
    }

    req.user = {
      id:           user.id,
      email:        user.email,
      fullName:     user.full_name,
      role:         user.role,
      firebaseUid:  user.firebase_uid
    };
    next();
  } catch (err) {
    next(err.isOperational ? err : new AppError('Invalid authentication token', 401, 'INVALID_TOKEN'));
  }
}

/**
 * Middleware: require a specific role
 * @param {...string} roles - allowed roles
 */
function requireRole(...roles) {
  return (req, res, next) => {
    if (!req.user) return next(new AppError('Unauthorized', 401, 'UNAUTHORIZED'));
    
    const userRole = (req.user.role || '').toLowerCase();
    const allowedRoles = roles.map(r => r.toLowerCase());
    
    // Let system_admin do anything admin can do
    if (userRole === 'system_admin') return next();

    if (!allowedRoles.includes(userRole)) {
      return next(new AppError(`Access denied. Required role: ${roles.join(' or ')}`, 403, 'FORBIDDEN'));
    }
    next();
  };
}

module.exports = { authenticateJWT, requireRole, signJWT, verifyJWT };
