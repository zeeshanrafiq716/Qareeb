import crypto from "node:crypto";
import { env } from "../config/env.js";
import { ENTITY, PROVIDER_STATUS } from "../config/constants.js";
import { getPool, query, withTransaction } from "../db/pool.js";
import { getStatus } from "../db/status.js";
import { logger } from "../logger.js";
import { AppError } from "../utils/AppError.js";
import { normalizePhone } from "../utils/phone.js";
import { signProviderToken } from "../utils/tokens.js";
import {
  fetchLocation,
  fetchLatestVerification,
  fetchProviderById,
  fetchProviderByPhone,
  recordStatusChange,
  serializeLocation,
  serializeProvider,
  serializeVerification,
} from "./serializers.js";

function hashOtp(code) {
  return crypto.createHash("sha256").update(String(code)).digest("hex");
}

function generateOtp() {
  if (env.OTP_STATIC_CODE) return env.OTP_STATIC_CODE;
  return String(crypto.randomInt(100000, 1000000));
}

async function nextPublicId(client) {
  const { rows } = await client.query("SELECT nextval('provider_public_id_seq') AS n");
  return `QRB-${rows[0].n}`;
}

export async function requestOtp(phoneInput, context = {}) {
  const phone = normalizePhone(phoneInput);

  const { rows: recent } = await query(
    `SELECT created_at FROM otp_codes
     WHERE phone = $1
     ORDER BY created_at DESC
     LIMIT 1`,
    [phone],
  );
  if (recent[0]) {
    const elapsed = (Date.now() - new Date(recent[0].created_at).getTime()) / 1000;
    if (elapsed < env.OTP_REQUEST_COOLDOWN_SECONDS) {
      throw new AppError(
        429,
        `Wait ${Math.ceil(env.OTP_REQUEST_COOLDOWN_SECONDS - elapsed)}s before requesting another OTP`,
        "OTP_COOLDOWN",
      );
    }
  }

  const windowStart = new Date(Date.now() - env.OTP_RATE_LIMIT_WINDOW_SECONDS * 1000);
  const phoneCount = await query(
    `SELECT COUNT(*)::int AS count FROM otp_request_audit
     WHERE phone = $1 AND created_at >= $2`,
    [phone, windowStart.toISOString()],
  );
  if (phoneCount.rows[0].count >= env.OTP_RATE_LIMIT_PER_PHONE) {
    throw new AppError(429, "Too many OTP requests for this phone number", "OTP_PHONE_RATE_LIMIT");
  }

  const otp = generateOtp();
  const expiresAt = new Date(Date.now() + env.OTP_EXPIRES_MINUTES * 60_000);

  await withTransaction(async (client) => {
    await client.query(
      `UPDATE otp_codes
       SET verified_at = now()
       WHERE phone = $1 AND verified_at IS NULL`,
      [phone],
    );

    await client.query(
      `INSERT INTO otp_codes (phone, code_hash, purpose, expires_at)
       VALUES ($1, $2, 'provider_register', $3)`,
      [phone, hashOtp(otp), expiresAt.toISOString()],
    );

    const existing = await fetchProviderByPhone(client, phone);
    if (!existing) {
      const pendingOtp = await getStatus(ENTITY.PROVIDER, PROVIDER_STATUS.PENDING_OTP);
      const publicId = await nextPublicId(client);
      const inserted = await client.query(
        `INSERT INTO providers (public_id, phone, status_id)
         VALUES ($1, $2, $3)
         RETURNING id, status_id`,
        [publicId, phone, pendingOtp.id],
      );
      await recordStatusChange(client, {
        providerId: inserted.rows[0].id,
        fromStatusId: null,
        toStatusId: pendingOtp.id,
        reason: "Provider registered",
      });
    }
  });

  await query(
    `INSERT INTO otp_request_audit (phone, ip_address, user_agent)
     VALUES ($1, $2, $3)`,
    [phone, context.ipAddress || null, context.userAgent || null],
  );

  logger.info({ phone }, "OTP generated");

  return {
    phone,
    expiresInMinutes: env.OTP_EXPIRES_MINUTES,
    message: "OTP sent to phone number",
    ...(env.OTP_RETURN_IN_RESPONSE || env.isTest ? { otp } : {}),
  };
}

export async function verifyOtp(phoneInput, otp) {
  const phone = normalizePhone(phoneInput);

  return withTransaction(async (client) => {
    const { rows } = await client.query(
      `SELECT * FROM otp_codes
       WHERE phone = $1 AND verified_at IS NULL
       ORDER BY created_at DESC
       LIMIT 1
       FOR UPDATE`,
      [phone],
    );
    const record = rows[0];
    if (!record) {
      throw new AppError(400, "No OTP found. Request a new one.", "OTP_NOT_FOUND");
    }
    if (new Date(record.expires_at).getTime() < Date.now()) {
      throw new AppError(400, "OTP has expired", "OTP_EXPIRED");
    }
    if (record.attempts >= env.OTP_MAX_ATTEMPTS) {
      throw new AppError(429, "Too many invalid OTP attempts", "OTP_LOCKED");
    }
    if (record.code_hash !== hashOtp(otp)) {
      await client.query(`UPDATE otp_codes SET attempts = attempts + 1 WHERE id = $1`, [record.id]);
      throw new AppError(400, "Invalid OTP", "OTP_INVALID");
    }

    await client.query(
      `UPDATE otp_codes SET verified_at = now(), attempts = attempts + 1 WHERE id = $1`,
      [record.id],
    );

    let provider = await fetchProviderByPhone(client, phone);
    if (!provider) {
      throw new AppError(404, "Provider not found", "PROVIDER_NOT_FOUND");
    }

    if (provider.status_code === PROVIDER_STATUS.PENDING_OTP) {
      const pendingProfile = await getStatus(ENTITY.PROVIDER, PROVIDER_STATUS.PENDING_PROFILE);
      await client.query(
        `UPDATE providers
         SET phone_verified_at = now(), status_id = $2, status_reason = NULL
         WHERE id = $1`,
        [provider.id, pendingProfile.id],
      );
      await recordStatusChange(client, {
        providerId: provider.id,
        fromStatusId: provider.status_id,
        toStatusId: pendingProfile.id,
        reason: "Phone verified",
      });
    } else if (!provider.phone_verified_at) {
      await client.query(`UPDATE providers SET phone_verified_at = now() WHERE id = $1`, [provider.id]);
    }

    provider = await fetchProviderById(client, provider.id);
    const location = await fetchLocation(client, provider.id);
    const verification = await fetchLatestVerification(client, provider.id);

    return {
      token: signProviderToken(provider),
      provider: serializeProvider(provider, {
        location: serializeLocation(location),
        verification: serializeVerification(verification),
      }),
    };
  });
}

export async function getMe(providerId) {
  const client = getPool();
  const provider = await fetchProviderById(client, providerId);
  if (!provider) throw new AppError(404, "Provider not found", "PROVIDER_NOT_FOUND");
  const location = await fetchLocation(client, providerId);
  const verification = await fetchLatestVerification(client, providerId);
  return serializeProvider(provider, {
    location: serializeLocation(location),
    verification: serializeVerification(verification),
  });
}
