import { query } from "../db/pool.js";
import { ENTITY } from "../config/constants.js";
import { getStatus } from "../db/status.js";
import { NotFoundError } from "../utils/AppError.js";

export const FUNNEL_EVENT = {
  LIST_IMPRESSION: "list_impression",
  PROFILE_CLICK: "profile_click",
  PROFILE_VIEW: "profile_view",
  CALL_CLICK: "call_click",
  WHATSAPP_CLICK: "whatsapp_click",
  SHARE_LOCATION_CLICK: "share_location_click",
};

const CALL_LOG_EVENTS = new Set([FUNNEL_EVENT.CALL_CLICK]);

export async function recordFunnelEvent({
  providerId,
  eventType,
  sessionId = null,
  latitude = null,
  longitude = null,
  metadata = {},
}) {
  const { rows } = await query(
    `INSERT INTO customer_funnel_events
       (provider_id, event_type, customer_session_id, customer_latitude, customer_longitude, metadata)
     VALUES ($1, $2, $3, $4, $5, $6::jsonb)
     RETURNING id, event_type, created_at`,
    [
      providerId,
      eventType,
      sessionId,
      latitude,
      longitude,
      JSON.stringify(metadata ?? {}),
    ],
  );

  if (CALL_LOG_EVENTS.has(eventType)) {
    const initiated = await getStatus(ENTITY.CALL, "initiated");
    await query(
      `INSERT INTO call_logs (provider_id, status_id, notes)
       VALUES ($1, $2, $3)`,
      [
        providerId,
        initiated.id,
        `customer_${eventType}${sessionId ? ` session=${sessionId}` : ""}`,
      ],
    );
  }

  return rows[0];
}

export async function recordListImpressions({ sessionId, providerIds, latitude, longitude }) {
  if (!providerIds?.length) return { inserted: 0 };
  const unique = [...new Set(providerIds)];
  const values = [];
  const params = [];
  let i = 1;
  for (const providerId of unique) {
    values.push(
      `($${i++}, $${i++}, $${i++}, $${i++}, $${i++}, '{}'::jsonb)`,
    );
    params.push(
      providerId,
      FUNNEL_EVENT.LIST_IMPRESSION,
      sessionId ?? null,
      latitude ?? null,
      longitude ?? null,
    );
  }
  await query(
    `INSERT INTO customer_funnel_events
       (provider_id, event_type, customer_session_id, customer_latitude, customer_longitude, metadata)
     VALUES ${values.join(", ")}`,
    params,
  );
  return { inserted: unique.length };
}

export async function resolveApprovedProviderByPublicId(publicId) {
  const { rows } = await query(
    `SELECT p.id, p.public_id, p.phone, s.code AS provider_status
     FROM providers p
     JOIN statuses s ON s.id = p.status_id
     WHERE p.public_id = $1`,
    [publicId],
  );
  const row = rows[0];
  if (!row || row.provider_status !== "approved") {
    throw new NotFoundError("Provider not found");
  }
  return row;
}

export async function trackCustomerDiscoveryEvent(input) {
  const provider = await resolveApprovedProviderByPublicId(input.providerPublicId);
  const lat = input.latitude ?? null;
  const lng = input.longitude ?? null;
  const row = await recordFunnelEvent({
    providerId: provider.id,
    eventType: input.event,
    sessionId: input.sessionId ?? null,
    latitude: lat,
    longitude: lng,
    metadata: input.metadata ?? {},
  });
  return {
    recorded: true,
    eventId: row.id,
    eventType: row.event_type,
    providerPublicId: provider.public_id,
  };
}

export async function getProviderFunnelSummary(providerId, { days = 30 } = {}) {
  const provider = await query(`SELECT id, public_id, name FROM providers WHERE id = $1`, [
    providerId,
  ]);
  if (!provider.rowCount) throw new NotFoundError("Provider not found");

  const { rows: counts } = await query(
    `SELECT event_type, COUNT(*)::int AS count
     FROM customer_funnel_events
     WHERE provider_id = $1
       AND created_at >= now() - ($2::int || ' days')::interval
     GROUP BY event_type`,
    [providerId, days],
  );

  const byType = Object.fromEntries(counts.map((r) => [r.event_type, r.count]));

  const { rows: callRows } = await query(
    `SELECT COUNT(*)::int AS count
     FROM call_logs
     WHERE provider_id = $1
       AND created_at >= now() - ($2::int || ' days')::interval`,
    [providerId, days],
  );

  return {
    providerId,
    publicId: provider.rows[0].public_id,
    name: provider.rows[0].name,
    windowDays: days,
    funnel: {
      listImpressions: byType.list_impression ?? 0,
      profileClicks: byType.profile_click ?? 0,
      profileViews: byType.profile_view ?? 0,
      callClicks: byType.call_click ?? 0,
      whatsappClicks: byType.whatsapp_click ?? 0,
      shareLocationClicks: byType.share_location_click ?? 0,
    },
    callLogsRecorded: callRows[0]?.count ?? 0,
  };
}

export async function getPlatformFunnelAnalytics({ days = 30 } = {}) {
  const { rows: counts } = await query(
    `SELECT event_type, COUNT(*)::int AS count
     FROM customer_funnel_events
     WHERE created_at >= now() - ($1::int || ' days')::interval
     GROUP BY event_type`,
    [days],
  );
  const byType = Object.fromEntries(counts.map((r) => [r.event_type, r.count]));

  const { rows: topProviders } = await query(
    `SELECT p.id, p.public_id, p.name,
            COUNT(*) FILTER (WHERE e.event_type = 'profile_view')::int AS profile_views,
            COUNT(*) FILTER (WHERE e.event_type = 'call_click')::int AS call_clicks
     FROM customer_funnel_events e
     JOIN providers p ON p.id = e.provider_id
     WHERE e.created_at >= now() - ($1::int || ' days')::interval
     GROUP BY p.id, p.public_id, p.name
     ORDER BY profile_views DESC, call_clicks DESC
     LIMIT 10`,
    [days],
  );

  const { rows: callTotals } = await query(
    `SELECT COUNT(*)::int AS total
     FROM call_logs
     WHERE created_at >= now() - ($1::int || ' days')::interval`,
    [days],
  );

  return {
    windowDays: days,
    totals: {
      listImpressions: byType.list_impression ?? 0,
      profileClicks: byType.profile_click ?? 0,
      profileViews: byType.profile_view ?? 0,
      callClicks: byType.call_click ?? 0,
      whatsappClicks: byType.whatsapp_click ?? 0,
      shareLocationClicks: byType.share_location_click ?? 0,
      callLogsRecorded: callTotals[0]?.total ?? 0,
    },
    topProvidersByEngagement: topProviders.map((row) => ({
      providerId: row.id,
      publicId: row.public_id,
      name: row.name,
      profileViews: row.profile_views,
      callClicks: row.call_clicks,
    })),
  };
}
