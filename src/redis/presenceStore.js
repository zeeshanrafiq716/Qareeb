import { env } from "../config/env.js";
import { getRedis } from "./client.js";
import { RedisKeys } from "./keys.js";
import { memoryPresenceStore, resetMemoryPresenceStore } from "./memoryStore.js";

let useMemory = !env.REDIS_ENABLED;

export function enableMemoryFallback() {
  useMemory = true;
}

export function forceMemoryPresenceForTests() {
  useMemory = true;
  resetMemoryPresenceStore();
}

export function resetPresenceStoreForTests() {
  resetMemoryPresenceStore();
}

async function redisOrMemory() {
  if (useMemory) return null;
  const redis = getRedis();
  if (!redis || redis.status !== "ready") {
    useMemory = true;
    return null;
  }
  return redis;
}

export const presenceStore = {
  async setOnline(providerId) {
    const redis = await redisOrMemory();
    if (!redis) return memoryPresenceStore.setOnline(providerId);
    const payload = JSON.stringify({ at: new Date().toISOString() });
    await redis.set(RedisKeys.online(providerId), payload, "EX", env.PRESENCE_STALE_SECONDS * 2);
    await redis.sadd(RedisKeys.onlineIndex, providerId);
  },

  async setOffline(providerId) {
    const redis = await redisOrMemory();
    if (!redis) return memoryPresenceStore.setOffline(providerId);
    await redis.del(RedisKeys.online(providerId));
    await redis.del(RedisKeys.sessions(providerId));
    await redis.srem(RedisKeys.onlineIndex, providerId);
  },

  async touch(providerId) {
    const redis = await redisOrMemory();
    if (!redis) return memoryPresenceStore.touch(providerId);
    await redis.set(
      RedisKeys.online(providerId),
      JSON.stringify({ at: new Date().toISOString() }),
      "EX",
      env.PRESENCE_STALE_SECONDS * 2,
    );
    await redis.sadd(RedisKeys.onlineIndex, providerId);
  },

  async isOnline(providerId) {
    const redis = await redisOrMemory();
    if (!redis) return memoryPresenceStore.isOnline(providerId);
    return (await redis.exists(RedisKeys.online(providerId))) === 1;
  },

  async addSession(providerId, socketId) {
    const redis = await redisOrMemory();
    if (!redis) return memoryPresenceStore.addSession(providerId, socketId);
    await redis.sadd(RedisKeys.sessions(providerId), socketId);
  },

  async removeSession(providerId, socketId) {
    const redis = await redisOrMemory();
    if (!redis) return memoryPresenceStore.removeSession(providerId, socketId);
    await redis.srem(RedisKeys.sessions(providerId), socketId);
    return await redis.scard(RedisKeys.sessions(providerId));
  },

  async sessionCount(providerId) {
    const redis = await redisOrMemory();
    if (!redis) return memoryPresenceStore.sessionCount(providerId);
    return await redis.scard(RedisKeys.sessions(providerId));
  },

  async setLocation(providerId, { latitude, longitude, updatedAt }) {
    const payload = { latitude, longitude, updatedAt };
    const redis = await redisOrMemory();
    if (!redis) return memoryPresenceStore.setLocation(providerId, payload);
    await redis.set(RedisKeys.location(providerId), JSON.stringify(payload), "EX", 86400);
  },

  async getLocation(providerId) {
    const redis = await redisOrMemory();
    if (!redis) return memoryPresenceStore.getLocation(providerId);
    const raw = await redis.get(RedisKeys.location(providerId));
    return raw ? JSON.parse(raw) : null;
  },

  async getLocationGate(providerId) {
    const redis = await redisOrMemory();
    if (!redis) return memoryPresenceStore.getLocationGate(providerId);
    const raw = await redis.get(RedisKeys.locationGate(providerId));
    return raw ? Number(raw) : null;
  },

  async setLocationGate(providerId, epochMs) {
    const redis = await redisOrMemory();
    if (!redis) return memoryPresenceStore.setLocationGate(providerId, epochMs);
    await redis.set(RedisKeys.locationGate(providerId), String(epochMs), "EX", 86400);
  },
};
