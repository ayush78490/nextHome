'use strict';

const winston = require('winston');
const path    = require('path');

const { combine, timestamp, errors, json, colorize, printf } = winston.format;

const devFormat = printf(({ level, message, timestamp, stack, ...meta }) => {
  const metaStr = Object.keys(meta).length ? `\n${JSON.stringify(meta, null, 2)}` : '';
  return `${timestamp} [${level}]: ${stack || message}${metaStr}`;
});

const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || (process.env.NODE_ENV === 'production' ? 'info' : 'debug'),
  format: combine(
    timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
    errors({ stack: true })
  ),
  transports: [
    // Console: dev-friendly or JSON in prod
    new winston.transports.Console({
      format: process.env.NODE_ENV === 'production'
        ? combine(json())
        : combine(colorize(), devFormat)
    }),
    // File: JSON logs for prod/OCI
    new winston.transports.File({
      filename: path.join(__dirname, '../../logs/error.log'),
      level: 'error',
      format: json(),
      maxsize: 10 * 1024 * 1024,  // 10 MB
      maxFiles: 5
    }),
    new winston.transports.File({
      filename: path.join(__dirname, '../../logs/combined.log'),
      format: json(),
      maxsize: 10 * 1024 * 1024,
      maxFiles: 10
    })
  ],
  exceptionHandlers: [
    new winston.transports.File({ filename: path.join(__dirname, '../../logs/exceptions.log') })
  ],
  rejectionHandlers: [
    new winston.transports.File({ filename: path.join(__dirname, '../../logs/rejections.log') })
  ]
});

module.exports = logger;
