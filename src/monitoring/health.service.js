import { query } from "../db/pool.js";
import { connectRedis, getRedis, isRedisAvailable } from "../redis/client.js";
import { env } from "../config/env.js";
import { isPostgisEnabled } from "../db/postgis.js";

export async function getReadinessCheck() {
  const checks = {
    database: { ok: false },
    redis: { ok: false, required: env.REDIS_ENABLED },
    postgis: { ok: false, optional: true },
  };

  try {
    await query("SELECT 1 AS ok");
    checks.database.ok = true;
  } catch (error) {
    checks.database.error = error.message;
  }

  if (env.REDIS_ENABLED) {
    try {
      if (!isRedisAvailable() && !env.isTest) await connectRedis();
      const redis = getRedis();
      if (redis && isRedisAvailable()) {
        await redis.ping();
        checks.redis.ok = true;
      } else if (env.isTest) {
        checks.redis.ok = true;
        checks.redis.skipped = true;
      } else {
        checks.redis.error = "Redis not connected";
      }
    } catch (error) {
      checks.redis.error = error.message;
    }
  } else {
    checks.redis.ok = true;
    checks.redis.skipped = true;
  }

  checks.postgis.ok = isPostgisEnabled();

  const healthy =
    checks.database.ok && (checks.redis.skipped || checks.redis.ok || !env.REDIS_ENABLED);

  return {
    status: healthy ? "ready" : "degraded",
    healthy,
    checks,
    phase: 5,
    timestamp: new Date().toISOString(),
  };
}
