import { env } from "../config/env.js";
import { query } from "../db/pool.js";
import { logger } from "../logger.js";
import { presenceStore } from "../redis/presenceStore.js";
import { AppError, NotFoundError } from "../utils/AppError.js";
import { sendFcmMessage } from "../utils/fcm.js";

const ALLOWED_REQUEST_STATUSES = new Set([
  "new",
  "active",
  "arrived",
  "in_progress",
  "completed",
  "cancelled",
]);

const UUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
const PROVIDER_NOTIFY_EVENTS = new Set([
  "call_click",
  "whatsapp_click",
  "share_location_click",
  "send_request_click",
  "request_cancelled",
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
    case "request_cancelled":
      return {
        title: "Request cancelled",
        body: "A customer cancelled their service request on Zesho.",
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
  const enrichedMetadata =
    eventType === "send_request_click"
      ? {
          requestStatus: "new",
          step: 0,
          ...(metadata ?? {}),
        }
      : (metadata ?? {});

  const { rows } = await query(
    `INSERT INTO provider_notifications
       (provider_id, event_type, title, body, customer_session_id, customer_latitude, customer_longitude, metadata)
     VALUES ($1, $2, $3, $4, $5, $6, $7, $8::jsonb)
     RETURNING id, event_type, title, body, customer_session_id, customer_latitude, customer_longitude, metadata, is_read, created_at`,
    [
      providerId,
      eventType,
      copy.title,
      copy.body,
      sessionId,
      latitude,
      longitude,
      JSON.stringify(enrichedMetadata),
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

export async function updateProviderRequestStatus(providerId, rawRequestId, { status, step } = {}) {
  const cleanId = String(rawRequestId || "").replace(/^REQ-/i, "").trim();
  if (!UUID_REGEX.test(cleanId)) {
    throw new AppError(400, "Invalid request ID", "INVALID_REQUEST_ID");
  }
  const normalizedStatus = String(status || "").trim().toLowerCase();
  if (!ALLOWED_REQUEST_STATUSES.has(normalizedStatus)) {
    throw new AppError(400, "Invalid request status", "INVALID_REQUEST_STATUS");
  }
  const defaultStepMap = {
    new: 0,
    active: 1,
    arrived: 2,
    in_progress: 3,
    completed: 4,
    cancelled: 0,
  };
  const resolvedStep = Number.isFinite(Number(step))
    ? Number(step)
    : (defaultStepMap[normalizedStatus] ?? 0);
  const updatedAt = new Date().toISOString();

  const patch = {
    requestStatus: normalizedStatus,
    step: resolvedStep,
    statusUpdatedAt: updatedAt,
    updatedBy: "provider",
    ...(normalizedStatus === "cancelled" ? { cancelledBy: "provider" } : {}),
  };

  const { rows } = await query(
    `UPDATE provider_notifications
     SET is_read = true,
         metadata = COALESCE(metadata, '{}'::jsonb) || $3::jsonb
     WHERE id = $1::uuid AND provider_id = $2 AND event_type = 'send_request_click'
     RETURNING id, event_type, title, body, customer_session_id, customer_latitude, customer_longitude, metadata, is_read, created_at`,
    [cleanId, providerId, JSON.stringify(patch)],
  );

  if (!rows[0]) {
    throw new NotFoundError("Service request not found");
  }

  return {
    requestId: rows[0].id,
    status: normalizedStatus,
    step: resolvedStep,
    updatedAt,
    notification: serializeProviderNotification(rows[0]),
  };
}

export async function getCustomerRequestStatus(rawRequestId) {
  const cleanId = String(rawRequestId || "").replace(/^REQ-/i, "").trim();
  if (!UUID_REGEX.test(cleanId)) {
    throw new AppError(400, "Invalid request ID", "INVALID_REQUEST_ID");
  }

  const { rows } = await query(
    `SELECT pn.id, pn.provider_id, pn.metadata, pn.created_at,
            p.public_id, p.name AS provider_name, p.phone AS provider_phone, p.photo_url AS provider_photo_url,
            p.rating_avg, p.rating_count,
            p.vehicle_type_name, p.vehicle_model, p.plate_number, p.vehicle_color,
            c.name AS category_name,
            COALESCE(ord.orders_count, 0) AS orders_count,
            l.latitude AS provider_lat, l.longitude AS provider_lng
     FROM provider_notifications pn
     JOIN providers p ON p.id = pn.provider_id
     LEFT JOIN categories c ON c.id = p.category_id
     LEFT JOIN locations l ON l.provider_id = p.id
     LEFT JOIN LATERAL (
       SELECT COUNT(*)::int AS orders_count
       FROM provider_notifications pn2
       WHERE pn2.provider_id = p.id
         AND pn2.event_type = 'send_request_click'
     ) ord ON true
     WHERE pn.id = $1::uuid AND pn.event_type = 'send_request_click'`,
    [cleanId],
  );

  const row = rows[0];
  if (!row) {
    throw new NotFoundError("Service request not found");
  }

  const meta = row.metadata && typeof row.metadata === "object" ? row.metadata : {};
  const liveRedisLoc = await presenceStore.getLocation(row.provider_id);
  const liveLat =
    liveRedisLoc && Number.isFinite(Number(liveRedisLoc.latitude))
      ? Number(liveRedisLoc.latitude)
      : (row.provider_lat != null ? Number(row.provider_lat) : null);
  const liveLng =
    liveRedisLoc && Number.isFinite(Number(liveRedisLoc.longitude))
      ? Number(liveRedisLoc.longitude)
      : (row.provider_lng != null ? Number(row.provider_lng) : null);

  return {
    requestId: row.id,
    status: String(meta.requestStatus || "new").toLowerCase(),
    step: Number(meta.step ?? 0),
    cancelledBy: meta.cancelledBy || null,
    updatedBy: meta.updatedBy || null,
    providerPublicId: row.public_id,
    providerName: row.provider_name,
    providerPhone: row.provider_phone,
    providerPhotoUrl: row.provider_photo_url,
    providerRatingAvg: Number(row.rating_avg ?? 0),
    providerRatingCount: Number(row.rating_count ?? 0),
    providerOrdersCount: Number(row.orders_count ?? 0),
    providerVehicleType: row.vehicle_type_name || null,
    providerVehicleModel: row.vehicle_model || null,
    providerPlateNumber: row.plate_number || null,
    providerVehicleColor: row.vehicle_color || null,
    providerLatitude: liveLat,
    providerLongitude: liveLng,
    serviceCategory: meta.serviceCategory || row.category_name || "",
    customerName: meta.customerName || "",
    customerAddress: meta.customerAddress || "",
    distance: meta.distance || "",
    updatedAt: meta.statusUpdatedAt || row.created_at,
    providerContactSeq: Number(meta.providerContactSeq ?? 0),
    lastProviderContact: meta.lastProviderContact ?? null,
  };
}

/** Provider tapped Call / WhatsApp on an active request — customer app polls this via getCustomerRequestStatus. */
export async function recordProviderContactAttempt(providerId, rawRequestId, { channel } = {}) {
  const cleanId = String(rawRequestId || "").replace(/^REQ-/i, "").trim();
  if (!UUID_REGEX.test(cleanId)) {
    throw new AppError(400, "Invalid request ID", "INVALID_REQUEST_ID");
  }
  const normalizedChannel =
    String(channel || "call").trim().toLowerCase() === "whatsapp" ? "whatsapp" : "call";
  const updatedAt = new Date().toISOString();
  const contactPayload = { channel: normalizedChannel, at: updatedAt, by: "provider" };

  const { rows } = await query(
    `UPDATE provider_notifications
     SET metadata = jsonb_set(
       jsonb_set(
         COALESCE(metadata, '{}'::jsonb),
         '{providerContactSeq}',
         to_jsonb(COALESCE((metadata->>'providerContactSeq')::int, 0) + 1),
         true
       ),
       '{lastProviderContact}',
       $3::jsonb,
       true
     )
     WHERE id = $1::uuid AND provider_id = $2 AND event_type = 'send_request_click'
     RETURNING id, metadata`,
    [cleanId, providerId, JSON.stringify(contactPayload)],
  );

  if (!rows[0]) {
    throw new NotFoundError("Service request not found");
  }

  const meta = rows[0].metadata && typeof rows[0].metadata === "object" ? rows[0].metadata : {};
  return {
    requestId: rows[0].id,
    providerContactSeq: Number(meta.providerContactSeq ?? 0),
    lastProviderContact: meta.lastProviderContact ?? contactPayload,
  };
}

export async function submitCustomerRequestRating(rawRequestId, { rating } = {}) {
  const cleanId = String(rawRequestId || "").replace(/^REQ-/i, "").trim();
  if (!UUID_REGEX.test(cleanId)) {
    throw new AppError(400, "Invalid request ID", "INVALID_REQUEST_ID");
  }
  const stars = Number(rating);
  if (!Number.isFinite(stars) || stars < 1 || stars > 5) {
    throw new AppError(400, "Rating must be between 1 and 5", "INVALID_RATING");
  }

  const { rows } = await query(
    `SELECT id, provider_id, metadata
     FROM provider_notifications
     WHERE id = $1::uuid AND event_type = 'send_request_click'`,
    [cleanId],
  );
  const row = rows[0];
  if (!row) {
    throw new NotFoundError("Service request not found");
  }

  const meta = row.metadata && typeof row.metadata === "object" ? row.metadata : {};
  if (meta.customerRating != null) {
    return {
      requestId: row.id,
      rating: Number(meta.customerRating),
      alreadySubmitted: true,
    };
  }

  const ratedAt = new Date().toISOString();
  await query(
    `UPDATE provider_notifications
     SET metadata = COALESCE(metadata, '{}'::jsonb) || $2::jsonb
     WHERE id = $1::uuid`,
    [
      cleanId,
      JSON.stringify({
        customerRating: stars,
        customerRatedAt: ratedAt,
      }),
    ],
  );

  await query(
    `UPDATE providers
     SET rating_count = rating_count + 1,
         rating_avg = CASE
           WHEN rating_count <= 0 THEN $2::numeric
           ELSE ROUND(((rating_avg * rating_count) + $2::numeric) / (rating_count + 1), 2)
         END
     WHERE id = $1`,
    [row.provider_id, stars],
  );

  return {
    requestId: row.id,
    rating: stars,
    ratedAt,
    alreadySubmitted: false,
  };
}

export async function cancelCustomerRequest(rawRequestId, { customerName } = {}) {
  const cleanId = String(rawRequestId || "").replace(/^REQ-/i, "").trim();
  if (!UUID_REGEX.test(cleanId)) {
    throw new AppError(400, "Invalid request ID", "INVALID_REQUEST_ID");
  }

  const updatedAt = new Date().toISOString();
  const patch = {
    requestStatus: "cancelled",
    step: 0,
    cancelledBy: "customer",
    updatedBy: "customer",
    statusUpdatedAt: updatedAt,
  };

  const { rows } = await query(
    `UPDATE provider_notifications
     SET metadata = COALESCE(metadata, '{}'::jsonb) || $2::jsonb
     WHERE id = $1::uuid AND event_type = 'send_request_click'
     RETURNING id, provider_id, customer_session_id, customer_latitude, customer_longitude, metadata`,
    [cleanId, JSON.stringify(patch)],
  );

  const original = rows[0];
  if (!original) {
    throw new NotFoundError("Service request not found");
  }

  const meta = original.metadata && typeof original.metadata === "object" ? original.metadata : {};
  const resolvedCustomerName =
    (customerName && String(customerName).trim()) ||
    (meta.customerName && String(meta.customerName).trim()) ||
    "Customer";
  const serviceCategory = (meta.serviceCategory && String(meta.serviceCategory).trim()) || "Service request";
  const cancelBody = `${resolvedCustomerName} cancelled the ${serviceCategory} request on Zesho.`;

  const inserted = await query(
    `INSERT INTO provider_notifications
       (provider_id, event_type, title, body, customer_session_id, customer_latitude, customer_longitude, metadata)
     VALUES ($1, 'request_cancelled', $2, $3, $4, $5, $6, $7::jsonb)
     RETURNING id, event_type, title, body, customer_session_id, customer_latitude, customer_longitude, metadata, is_read, created_at`,
    [
      original.provider_id,
      "Request cancelled",
      cancelBody,
      original.customer_session_id,
      original.customer_latitude,
      original.customer_longitude,
      JSON.stringify({
        requestId: original.id,
        serviceCategory,
        customerName: resolvedCustomerName,
        cancelledBy: "customer",
      }),
    ],
  );

  await sendPushToProvider(original.provider_id, {
    title: "Request cancelled",
    body: cancelBody,
    data: {
      eventType: "request_cancelled",
      requestId: original.id,
      notificationId: inserted.rows[0]?.id,
    },
  }).catch(() => {});

  return {
    requestId: original.id,
    status: "cancelled",
    cancelledBy: "customer",
    updatedAt,
    notification: inserted.rows[0] ? serializeProviderNotification(inserted.rows[0]) : null,
  };
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
