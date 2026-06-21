'use strict';

const { Server }    = require('socket.io');
const { verifyJWT } = require('../middleware/auth');
const { getRedis }  = require('../config/redis');
const logger        = require('../config/logger');

// Safe no-op helpers when Redis / DB are unavailable during dev
const safeRedis = {
  setex: async () => {},
  del:   async () => {},
  publish: async () => {},
};

/**
 * Socket.IO Server Initialization
 * Handles: Chat rooms, real-time notifications, online presence
 */
function initSocket(httpServer) {
  const io = new Server(httpServer, {
    cors: {
      origin: process.env.ALLOWED_ORIGINS?.split(',') || '*',
      credentials: true
    },
    transports: ['websocket', 'polling'],
    pingInterval: 10000,
    pingTimeout: 5000
  });

  // ── JWT Authentication Middleware ──────────────────────────────────────────
  io.use(async (socket, next) => {
    try {
      const token = socket.handshake.auth?.token || socket.handshake.headers?.authorization?.split('Bearer ')[1];
      if (!token) return next(new Error('Authentication token required'));
      const decoded = verifyJWT(token);
      socket.user = decoded;
      next();
    } catch (err) {
      next(new Error('Invalid token'));
    }
  });

  // ── Connection Handler ─────────────────────────────────────────────────────
  io.on('connection', async (socket) => {
    const userId = socket.user.id;
    logger.info(`Socket connected: userId=${userId} socketId=${socket.id}`);

    // Track online status in Redis (safe no-op when Redis is down)
    const redis = getRedis() ?? safeRedis;
    await redis.setex(`online:${userId}`, 120, socket.id);

    // Auto-join user's personal notification room
    socket.join(`user:${userId}`);

    // ── Chat Events ───────────────────────────────────────────────────────────

    /** Join a chat room */
    socket.on('chat:join', async ({ roomId }) => {
      try {
        socket.join(`room:${roomId}`);
        socket.emit('chat:joined', { roomId });
        logger.debug(`User ${userId} joined room ${roomId}`);
      } catch (err) {
        logger.error('chat:join error:', err);
      }
    });

    /** Send a message */
    socket.on('chat:message', async ({ roomId, content, messageType = 'text' }) => {
      try {
        if (!roomId || !content?.trim()) {
          return socket.emit('error', { code: 'VALIDATION_ERROR', message: 'roomId and content required' });
        }

        // Persist message to DB
        const msgResult = await query(
          `INSERT INTO messages (room_id, sender_id, message_type, content)
           VALUES (:roomId, :senderId, :messageType, :content)
           RETURNING id, created_at INTO :msgId, :createdAt`,
          {
            roomId, senderId: userId, messageType, content,
            msgId:     { type: require('oracledb').STRING, dir: require('oracledb').BIND_OUT, maxSize: 36 },
            createdAt: { type: require('oracledb').DATE,   dir: require('oracledb').BIND_OUT }
          }
        );

        const message = {
          id:          msgResult.outBinds.msgId,
          roomId,
          senderId:    userId,
          messageType,
          content,
          createdAt:   msgResult.outBinds.createdAt
        };

        // Broadcast to all room participants
        io.to(`room:${roomId}`).emit('chat:message', message);

        // Publish to Redis for multi-instance scenarios
        await redis.publish('nexthome:messages', JSON.stringify(message));
      } catch (err) {
        logger.error('chat:message error:', err);
        socket.emit('error', { code: 'INTERNAL_ERROR', message: 'Failed to send message' });
      }
    });

    /** Mark messages as read */
    socket.on('chat:read', async ({ roomId }) => {
      try {
        await query(
          `UPDATE messages SET is_read = 1, read_at = SYSTIMESTAMP
           WHERE room_id = :roomId AND sender_id != :userId AND is_read = 0`,
          { roomId, userId }
        );
        io.to(`room:${roomId}`).emit('chat:read', { roomId, readBy: userId });
      } catch (err) {
        logger.error('chat:read error:', err);
      }
    });

    /** Typing indicator */
    socket.on('chat:typing', ({ roomId, isTyping }) => {
      socket.to(`room:${roomId}`).emit('chat:typing', { userId, isTyping });
    });

    // ── Presence ──────────────────────────────────────────────────────────────
    socket.on('presence:ping', async () => {
      await redis.setex(`online:${userId}`, 120, socket.id);
    });

    // ── Disconnect ────────────────────────────────────────────────────────────
    socket.on('disconnect', async (reason) => {
      logger.info(`Socket disconnected: userId=${userId} reason=${reason}`);
      await redis.del(`online:${userId}`);
      io.emit('presence:offline', { userId });
    });
  });

  logger.info('Socket.IO server initialized');
  return io;
}

module.exports = initSocket;
