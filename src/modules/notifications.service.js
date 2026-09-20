import { env } from "../config/env.js";
import { query } from "../db/pool.js";
import { logger } from "../logger.js";
import { AppError, NotFoundError } from "../utils/AppError.js";
import { sendFcmMessage } from "../utils/fcm.js";

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
