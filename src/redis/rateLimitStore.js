import { getRedis, isRedisAvailable } from "./client.js";

const memory = new Map();

function memoryIncrement(key, windowSeconds, limit) {
  const now = Date.now();
  let entry = memory.get(key);
  if (!entry || entry.resetAt <= now) {
    entry = { count: 0, resetAt: now + windowSeconds * 1000 };
    memory.set(key, entry);
  }
  entry.count += 1;
  const allowed = entry.count <= limit;
  const retryAfterSeconds = allowed ? 0 : Math.ceil((entry.resetAt - now) / 1000);
  return {
    allowed,
    remaining: Math.max(0, limit - entry.count),
    retryAfterSeconds,
  };
}

/** Sliding window counter (Redis INCR + EXPIRE, in-memory fallback). */
export async function incrementRateLimit(key, windowSeconds, limit) {
  const redis = getRedis();
  if (redis && isRedisAvailable()) {
    try {
      const count = await redis.incr(key);
      if (count === 1) {
        await redis.expire(key, windowSeconds);
      }
      const ttl = await redis.ttl(key);
      const allowed = count <= limit;
      return {
        allowed,
        remaining: Math.max(0, limit - count),
        retryAfterSeconds: allowed ? 0 : Math.max(1, ttl),
      };
    } catch {
      return memoryIncrement(key, windowSeconds, limit);
    }
  }
  return memoryIncrement(key, windowSeconds, limit);
}

export function resetRateLimitMemoryForTests() {
  memory.clear();
}
