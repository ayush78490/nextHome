'use strict';

const rateLimit = require('express-rate-limit');
const { getRedis } = require('../config/redis');

/**
 * General API rate limiter – 100 req / 15 min per IP
 */
const rateLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    success: false,
    code: 'TOO_MANY_REQUESTS',
    message: 'Too many requests. Please try again later.'
  },
  skip: (req) => req.path === '/health'
});

/**
 * Strict auth rate limiter – 10 req / 15 min per IP
 */
const authRateLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 10,
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    success: false,
    code: 'TOO_MANY_AUTH_REQUESTS',
    message: 'Too many authentication attempts. Please wait 15 minutes.'
  }
});

module.exports = rateLimiter;
module.exports.authRateLimiter = authRateLimiter;
