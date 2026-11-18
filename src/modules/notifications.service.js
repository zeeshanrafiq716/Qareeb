import { env } from "../config/env.js";
import { query } from "../db/pool.js";
import { logger } from "../logger.js";
import { AppError, NotFoundError } from "../utils/AppError.js";
import { sendFcmMessage } from "../utils/fcm.js";
const PROVIDER_NOTIFY_EVENTS = new Set([
  "call_click",
  "whatsapp_click",
  "share_location_click",
  "send_request_click",
]);

function notificationCopy(eventType) {
  switch (eventType) {
    case "call_click":
      return {
        title: "Incoming call",
        body: "A customer tapped Call on your Zesho profile.",
      };
    case "whatsapp_click":
      return {
        title: "WhatsApp contact",
        body: "A customer opened WhatsApp to reach you on Zesho.",
      };
    case "share_location_click":
      return {
        title: "Location shared",
        body: "A customer is sharing their location with you on Zesho.",
      };
    case "send_request_click":
      return {
        title: "New service request",
        body: "A customer sent you a service request on Zesho.",
      };
    default:
      return { title: "Customer activity", body: "New customer activity on your profile." };
  }
}

function serializeProviderNotification(row) {
  return {
    id: row.id,
    eventType: row.event_type,
    title: row.title,
    body: row.body,
    customerSessionId: row.customer_session_id,
    customerLatitude: row.customer_latitude != null ? Number(row.customer_latitude) : null,
    customerLongitude: row.customer_longitude != null ? Number(row.customer_longitude) : null,
    metadata: row.metadata ?? {},
    isRead: row.is_read,
    createdAt: row.created_at,
  };
}

export async function notifyProviderForCustomerEvent({
  providerId,
  eventType,
  sessionId = null,
  latitude = null,
  longitude = null,
  metadata = {},
}) {
  if (!PROVIDER_NOTIFY_EVENTS.has(eventType)) {
    return { skipped: true, reason: "event_not_notifiable" };
  }

  const copy = notificationCopy(eventType);
  const { rows } = await query(
    `INSERT INTO provider_notifications
       (provider_id, event_type, title, body, customer_session_id, customer_latitude, customer_longitude, metadata)
     VALUES ($1, $2, $3, $4, $5, $6, $7, $8::jsonb)
     RETURNING id, event_type, title, body, created_at`,
    [
      providerId,
      eventType,
      copy.title,
      copy.body,
      sessionId,
      latitude,
      longitude,
      JSON.stringify(metadata ?? {}),
    ],
  );

  const push = await sendPushToProvider(providerId, {
    title: copy.title,
    body: copy.body,
    data: {
      eventType,
      notificationId: rows[0].id,
    },
  });

  return { notification: serializeProviderNotification(rows[0]), push };
}

export async function listProviderNotifications(providerId, { limit = 20 } = {}) {
  const safeLimit = Math.min(50, Math.max(1, Number(limit) || 20));
  const { rows } = await query(
    `SELECT id, event_type, title, body, customer_session_id, customer_latitude, customer_longitude, metadata, is_read, created_at
     FROM provider_notifications
     WHERE provider_id = $1
     ORDER BY created_at DESC
     LIMIT $2`,
    [providerId, safeLimit],
  );
  const unread = await query(
    `SELECT COUNT(*)::int AS c FROM provider_notifications WHERE provider_id = $1 AND is_read = false`,
    [providerId],
  );
  return {
    items: rows.map(serializeProviderNotification),
    unreadCount: unread.rows[0]?.c ?? 0,
  };
}

export async function markProviderNotificationsRead(providerId, { ids = null } = {}) {
  if (Array.isArray(ids) && ids.length > 0) {
    await query(
      `UPDATE provider_notifications SET is_read = true
       WHERE provider_id = $1 AND id = ANY($2::uuid[])`,
      [providerId, ids],
    );
  } else {
    await query(
      `UPDATE provider_notifications SET is_read = true WHERE provider_id = $1 AND is_read = false`,
      [providerId],
    );
  }
  return { success: true };
}

export async function registerProviderDeviceToken(providerId, { token, platform, appVersion }) {
  if (!token?.trim()) {
    throw new AppError(400, "FCM token is required", "INVALID_FCM_TOKEN");
  }
  const safePlatform = platform || "android";
  const { rows } = await query(
    `INSERT INTO provider_device_tokens (provider_id, fcm_token, platform, app_version, updated_at)
     VALUES ($1, $2, $3, $4, now())
     ON CONFLICT (provider_id, fcm_token)
     DO UPDATE SET platform = EXCLUDED.platform, app_version = EXCLUDED.app_version, updated_at = now()
     RETURNING id, provider_id, platform, updated_at`,
    [providerId, token.trim(), safePlatform, appVersion || null],
  );
  return rows[0];
}

export async function removeProviderDeviceToken(providerId, token) {
  await query(
    `DELETE FROM provider_device_tokens WHERE provider_id = $1 AND fcm_token = $2`,
    [providerId, token.trim()],
  );
  return { removed: true };
}

async function tokensForProvider(providerId) {
  const { rows } = await query(
    `SELECT fcm_token FROM provider_device_tokens WHERE provider_id = $1 ORDER BY updated_at DESC`,
    [providerId],
  );
  return rows.map((r) => r.fcm_token);
}

export async function sendPushToProvider(providerId, { title, body, data = {} }) {
  const provider = await query(`SELECT id, public_id, name FROM providers WHERE id = $1`, [providerId]);
  if (!provider.rowCount) throw new NotFoundError("Provider not found");

  const tokens = await tokensForProvider(providerId);
  if (!tokens.length) {
    return { sent: 0, failed: 0, reason: "no_device_tokens" };
  }

  let sent = 0;
  let failed = 0;
  for (const token of tokens) {
    try {
      await sendFcmMessage({ token, title, body, data });
      sent += 1;
    } catch (error) {
      failed += 1;
      logger.warn({ err: error, providerId, tokenPrefix: token.slice(0, 12) }, "FCM send failed");
    }
  }
  return { sent, failed, totalTokens: tokens.length };
}

export async function sendAdminPush(input) {
  if (!env.FCM_ENABLED) {
    throw new AppError(503, "Push notifications are not configured on the server", "FCM_DISABLED");
  }
  return sendPushToProvider(input.providerId, {
    title: input.title,
    body: input.body,
    data: input.data ?? {},
  });
}
