'use strict';

require('dotenv').config({ override: true });
const express     = require('express');
const http        = require('http');
const cors        = require('cors');
const helmet      = require('helmet');
const morgan      = require('morgan');
const compression = require('compression');

const logger        = require('./config/logger');

const { connectRedis } = require('./config/redis');
const initSocket    = require('./socket/socket.handler');
const rateLimiter   = require('./middleware/rateLimiter');
const { errorHandler }  = require('./middleware/errorHandler');
const notFound      = require('./middleware/notFound');

// ── Feature Routes ────────────────────────────────────────────────────────────
const authRoutes         = require('./features/auth/auth.routes');
const propertiesRoutes   = require('./features/properties/properties.routes');
const adminRoutes        = require('./features/admin/admin.routes');
const bookingsRoutes     = require('./features/bookings/bookings.routes');
const paymentsRoutes     = require('./features/payments/payments.routes');
const chatRoutes         = require('./features/chat/chat.routes');
const notificationsRoutes = require('./features/notifications/notifications.routes');

// ── App Factory ───────────────────────────────────────────────────────────────
function createApp() {
  const app = express();
  const server = http.createServer(app);

  // ── Trust proxy (for OCI load balancer) ─────────────────────────────────
  app.set('trust proxy', 1);

  // ── Security Middleware ──────────────────────────────────────────────────
  app.use(helmet({
    crossOriginResourcePolicy: { policy: 'cross-origin' }
  }));

  app.use(cors({
    origin: process.env.ALLOWED_ORIGINS?.split(',') || ['http://localhost:3000'],
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'X-Request-ID']
  }));

  // ── General Middleware ───────────────────────────────────────────────────
  app.use(compression());
  app.use(express.json({ limit: '10mb' }));
  app.use(express.urlencoded({ extended: true, limit: '10mb' }));
  app.use(morgan('combined', { stream: { write: (msg) => logger.info(msg.trim()) } }));
  app.use(rateLimiter);

  // ── Health Check ─────────────────────────────────────────────────────────
  app.get('/health', (req, res) => {
    res.json({
      status: 'ok',
      service: 'nexthome-backend',
      version: process.env.npm_package_version || '1.0.0',
      timestamp: new Date().toISOString(),
      environment: process.env.NODE_ENV
    });
  });

  // ── API Routes ───────────────────────────────────────────────────────────
  const API_PREFIX = '/api/v1';
  app.use(`${API_PREFIX}/auth`,          authRoutes);

  app.use(`${API_PREFIX}/properties`,    propertiesRoutes);
  app.use(`${API_PREFIX}/admin`,         adminRoutes);
  app.use(`${API_PREFIX}/bookings`,      bookingsRoutes);
  app.use(`${API_PREFIX}/payments`,      paymentsRoutes);
  app.use(`${API_PREFIX}/chat`,          chatRoutes);
  app.use(`${API_PREFIX}/notifications`, notificationsRoutes);

  // ── 404 & Error Handlers ─────────────────────────────────────────────────
  app.use(notFound);
  app.use(errorHandler);

  // ── Socket.IO ────────────────────────────────────────────────────────────
  initSocket(server);

  return { app, server };
}

// ── Bootstrap ─────────────────────────────────────────────────────────────────
async function bootstrap() {
  try {

    await connectRedis();
    logger.info('Redis connected');

    const { server } = createApp();

    const PORT = process.env.PORT || 3000;
    server.listen(PORT, '0.0.0.0', () => {
      logger.info(`🚀 Next Home API running on port ${PORT} [${process.env.NODE_ENV}]`);
    });

    // ── Graceful Shutdown ───────────────────────────────────────────────────
    const gracefulShutdown = async (signal) => {
      logger.info(`${signal} received – shutting down gracefully...`);
      server.close(async () => {
        const { closeRedis } = require('./config/redis');
        await Promise.allSettled([closeRedis()]);
        logger.info('Server shut down cleanly');
        process.exit(0);
      });
      setTimeout(() => { logger.error('Forced exit after timeout'); process.exit(1); }, 30000);
    };

    process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
    process.on('SIGINT',  () => gracefulShutdown('SIGINT'));
    process.on('uncaughtException', (err) => {
      logger.error('Uncaught Exception:', err);
      process.exit(1);
    });
    process.on('unhandledRejection', (reason) => {
      logger.error('Unhandled Rejection:', reason);
      process.exit(1);
    });

  } catch (err) {
    logger.error('Bootstrap failed:', err);
    process.exit(1);
  }
}

bootstrap();

module.exports = createApp; // For testing
