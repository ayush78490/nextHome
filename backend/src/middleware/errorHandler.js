'use strict';

const logger = require('../config/logger');

/**
 * Custom application error class
 */
class AppError extends Error {
  constructor(message, statusCode = 500, code = 'INTERNAL_ERROR') {
    super(message);
    this.statusCode = statusCode;
    this.code       = code;
    this.isOperational = true;
    Error.captureStackTrace(this, this.constructor);
  }
}

/**
 * Global error handler middleware
 */
function errorHandler(err, req, res, next) { // eslint-disable-line no-unused-vars
  const isDev = process.env.NODE_ENV === 'development';

  // Log the error
  if (err.isOperational) {
    logger.warn(`[${err.code}] ${err.message}`, { path: req.path, method: req.method });
  } else {
    logger.error('Unexpected error:', { err, path: req.path });
  }

  // Oracle DB errors
  if (err.errorNum) {
    switch (err.errorNum) {
      case 1: // ORA-00001: unique constraint violated
        return res.status(409).json({ success: false, code: 'DUPLICATE_ENTRY', message: 'Resource already exists' });
      case 904:  // ORA-00904: invalid identifier
      case 942:  // ORA-00942: table or view does not exist
        return res.status(500).json({ success: false, code: 'DB_ERROR', message: 'Database error' });
      case 1403: // ORA-01403: no data found
        return res.status(404).json({ success: false, code: 'NOT_FOUND', message: 'Resource not found' });
      default:
        logger.error('Oracle error:', { errorNum: err.errorNum, message: err.message });
        return res.status(500).json({ success: false, code: 'DB_ERROR', message: 'Database error' });
    }
  }

  // JWT errors
  if (err.name === 'JsonWebTokenError') {
    return res.status(401).json({ success: false, code: 'INVALID_TOKEN', message: 'Invalid token' });
  }
  if (err.name === 'TokenExpiredError') {
    return res.status(401).json({ success: false, code: 'TOKEN_EXPIRED', message: 'Token expired' });
  }

  // Validation errors (Joi)
  if (err.isJoi) {
    return res.status(400).json({
      success: false,
      code: 'VALIDATION_ERROR',
      message: err.details[0]?.message || 'Validation failed',
      errors: err.details?.map(d => ({ field: d.path.join('.'), message: d.message }))
    });
  }

  const statusCode = err.statusCode || 500;
  const code       = err.code || 'INTERNAL_ERROR';
  const message    = err.isOperational ? err.message : 'Internal server error';

  res.status(statusCode).json({
    success: false,
    code,
    message,
    ...(isDev && { stack: err.stack })
  });
}

module.exports = { errorHandler: errorHandler, AppError };
