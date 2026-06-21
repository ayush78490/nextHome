'use strict';

const { AppError } = require('./errorHandler');

module.exports = (req, res, next) => {
  next(new AppError(`Route ${req.method} ${req.originalUrl} not found`, 404, 'NOT_FOUND'));
};
