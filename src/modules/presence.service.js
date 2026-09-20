import { env } from "../config/env.js";
import { PROVIDER_STATUS } from "../config/constants.js";
import { query } from "../db/pool.js";
import { hasLiveConnection } from "../realtime/connections.js";
import { PROVIDER_SELECT, serializeProvider } from "./serializers.js";

export function buildPresence(row) {
  const lastSeenAt = row.last_seen_at ?? null;
  const isOnline = Boolean(row.is_online);
  let isStale = false;
  if (isOnline && lastSeenAt) {
    const ageMs = Date.now() - new Date(lastSeenAt).getTime();
    isStale = ageMs > env.PRESENCE_STALE_SECONDS * 1000;
  }
  return {
    isOnline,
    lastSeenAt,
    isStale,
    hasLiveSocket: hasLiveConnection(row.id),
  };
}

export async function setOnline(providerId) {
  await query(
    `UPDATE providers SET is_online = true, last_seen_at = now() WHERE id = $1`,
    [providerId],
  );
}

export async function setOffline(providerId) {
  await query(
    `UPDATE providers SET is_online = false, last_seen_at = now() WHERE id = $1`,
    [providerId],
  );
}

export async function touchLastSeen(providerId) {
  await query(
    `UPDATE providers SET is_online = true, last_seen_at = now() WHERE id = $1`,
    [providerId],
  );
}

/** Mark DB-online providers offline when heartbeat is too old (and no live socket). */
export async function sweepStaleProviders() {
  const { rows } = await query(
    `SELECT id FROM providers
     WHERE is_online = true
       AND last_seen_at IS NOT NULL
       AND last_seen_at < now() - ($1 * interval '1 second')`,
    [env.PRESENCE_STALE_SECONDS],
  );

  let updated = 0;
  for (const row of rows) {
    if (hasLiveConnection(row.id)) {
      await touchLastSeen(row.id);
      continue;
    }
    await setOffline(row.id);
    updated += 1;
  }
  return updated;
}

export async function getProviderPresence(providerId) {
  const { rows } = await query(`${PROVIDER_SELECT} WHERE p.id = $1`, [providerId]);
  if (!rows[0]) return null;
  return {
    ...serializeProvider(rows[0]),
    presence: buildPresence(rows[0]),
  };
}

export async function listOnlineProviders({ page = 1, limit = 20 } = {}) {
  const safeLimit = Math.min(100, Math.max(1, Number(limit) || 20));
  const safePage = Math.max(1, Number(page) || 1);
  const offset = (safePage - 1) * safeLimit;

  const count = await query(
    `SELECT COUNT(*)::int AS total
     FROM providers p
     JOIN statuses s ON s.id = p.status_id
     WHERE s.code = $1 AND p.is_online = true`,
    [PROVIDER_STATUS.APPROVED],
  );

  const { rows } = await query(
    `${PROVIDER_SELECT}
     WHERE s.code = $1 AND p.is_online = true
     ORDER BY p.last_seen_at DESC NULLS LAST
     LIMIT $2 OFFSET $3`,
    [PROVIDER_STATUS.APPROVED, safeLimit, offset],
  );

  return {
    items: rows.map((row) => ({
      ...serializeProvider(row),
      presence: buildPresence(row),
    })),
    meta: {
      page: safePage,
      limit: safeLimit,
      total: count.rows[0].total,
      totalPages: Math.max(1, Math.ceil(count.rows[0].total / safeLimit)),
    },
  };
}
