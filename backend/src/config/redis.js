'use strict';

const Redis  = require('ioredis');
const logger = require('./logger');

let redisClient  = null;
let redisEnabled = false; // flipped to true only when Redis connects successfully

const redisConfig = {
  host:         process.env.REDIS_HOST     || 'localhost',
  port:         parseInt(process.env.REDIS_PORT || '6379'),
  password:     process.env.REDIS_PASSWORD || undefined,
  db:           0,
  retryStrategy: () => null, // do NOT auto-retry — fail fast so server still starts
  lazyConnect:  true,
  enableReadyCheck: true,
  maxRetriesPerRequest: 1,
};

async function connectRedis() {
  try {
    const client = new Redis(redisConfig);
    client.on('error', (err) => logger.warn(`Redis error (non-fatal): ${err.message}`));

    await client.connect();
    await client.ping();

    redisClient  = client;
    redisEnabled = true;
    logger.info('Redis connected ✓');
  } catch (err) {
    logger.warn(`⚠️  Redis unavailable — running without cache (${err.message})`);
    // Do NOT rethrow — server starts anyway
  }
}

function getRedis() {
  return redisEnabled ? redisClient : null;
}

async function closeRedis() {
  if (redisClient) {
    await redisClient.quit().catch(() => {});
    logger.info('Redis connection closed');
  }
}

// ── Cache Helpers (all are no-ops when Redis is down) ─────────────────────────
async function cacheGet(key) {
  if (!redisEnabled) return null;
  const val = await redisClient.get(key);
  return val ? JSON.parse(val) : null;
}

async function cacheSet(key, value, ttlSeconds = 300) {
  if (!redisEnabled) return;
  await redisClient.setex(key, ttlSeconds, JSON.stringify(value));
}

async function cacheDel(key) {
  if (!redisEnabled) return;
  await redisClient.del(key);
}

async function cacheDelPattern(pattern) {
  if (!redisEnabled) return;
  const keys = await redisClient.keys(pattern);
  if (keys.length > 0) await redisClient.del(...keys);
}

module.exports = { connectRedis, getRedis, closeRedis, cacheGet, cacheSet, cacheDel, cacheDelPattern };
