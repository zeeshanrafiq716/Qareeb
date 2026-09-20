import Redis from "ioredis";
import { env } from "../config/env.js";
import { logger } from "../logger.js";

let client;
let redisAvailable = false;
let redisDisabled = false;
let onFallback;

/** Register callback when Redis is disabled (avoids circular import with presenceStore). */
export function onRedisFallback(fn) {
  onFallback = fn;
}

export function isRedisAvailable() {
  return redisAvailable;
}

function disableRedis(reason) {
  if (redisDisabled) return;
  redisDisabled = true;
  redisAvailable = false;
  if (client) {
    client.removeAllListeners();
    client.disconnect(false);
    client = null;
  }
  logger.warn({ reason }, "Redis unavailable — using in-memory presence (set REDIS_ENABLED=false to hide this)");
  onFallback?.();
}

export function getRedis() {
  if (!env.REDIS_ENABLED || redisDisabled) return null;
  if (!client) {
    client = new Redis(env.REDIS_URL, {
      lazyConnect: true,
      enableOfflineQueue: false,
      maxRetriesPerRequest: 1,
      retryStrategy: () => null,
      reconnectOnError: () => false,
    });
    client.on("error", (err) => {
      disableRedis(err.message);
    });
  }
  return client;
}

export async function connectRedis() {
  if (!env.REDIS_ENABLED) {
    onFallback?.();
    return false;
  }
  const redis = getRedis();
  if (!redis) return false;
  if (redisAvailable && redis.status === "ready") return true;

  try {
    await redis.connect();
    await redis.ping();
    redisAvailable = true;
    logger.info({ url: env.REDIS_URL }, "Redis connected");
    return true;
  } catch (error) {
    disableRedis(error.message);
    return false;
  }
}

export async function closeRedis() {
  if (client) {
    try {
      await client.quit();
    } catch {
      client.disconnect(false);
    }
    client = null;
  }
  redisAvailable = false;
}
