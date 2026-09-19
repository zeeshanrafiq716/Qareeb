import { ENTITY, PROVIDER_STATUS, VERIFICATION_STATUS } from "../config/constants.js";
import { query, withTransaction } from "../db/pool.js";
import { getStatus } from "../db/status.js";
import { AppError, NotFoundError } from "../utils/AppError.js";
import {
  fetchLatestVerification,
  fetchLocation,
  fetchProviderById,
  recordStatusChange,
  serializeLocation,
  serializeProvider,
  serializeVerification,
} from "./serializers.js";

async function assertEnabledCategory(client, categoryId) {
  const { rows } = await client.query(
    `SELECT id, name, is_enabled FROM categories WHERE id = $1`,
    [categoryId],
  );
  if (!rows[0]) throw new NotFoundError("Category not found");
  if (!rows[0].is_enabled) {
    throw new AppError(400, "Category is disabled", "CATEGORY_DISABLED");
  }
  return rows[0];
}

async function upsertLocation(client, providerId, input) {
  const hasLocation =
    input.address || input.city || input.latitude !== undefined || input.longitude !== undefined;
  if (!hasLocation) {
    return fetchLocation(client, providerId);
  }

  await client.query(
    `INSERT INTO locations (provider_id, latitude, longitude, address, city)
     VALUES ($1, $2, $3, $4, $5)
     ON CONFLICT (provider_id) DO UPDATE
     SET latitude = EXCLUDED.latitude,
         longitude = EXCLUDED.longitude,
         address = EXCLUDED.address,
         city = EXCLUDED.city`,
    [
      providerId,
      input.latitude ?? null,
      input.longitude ?? null,
      input.address || null,
      input.city || null,
    ],
  );
  return fetchLocation(client, providerId);
}

function canEditProfile(statusCode) {
  return statusCode !== PROVIDER_STATUS.SUSPENDED;
}

export async function updateProfile(provider, input) {
  if (!canEditProfile(provider.status_code)) {
    throw new AppError(403, "Suspended providers cannot update profile", "PROVIDER_SUSPENDED");
  }

  return withTransaction(async (client) => {
    await assertEnabledCategory(client, input.categoryId);

    await client.query(
      `UPDATE providers
       SET name = $2, category_id = $3, photo_url = COALESCE($4, photo_url)
       WHERE id = $1`,
      [provider.id, input.name, input.categoryId, input.photoUrl || null],
    );

    await upsertLocation(client, provider.id, input);

    let next = await fetchProviderById(client, provider.id);
    if (next.status_code === PROVIDER_STATUS.PENDING_OTP) {
      throw new AppError(400, "Verify OTP before submitting profile", "OTP_REQUIRED");
    }

    const verification = await fetchLatestVerification(client, provider.id);
    const location = await fetchLocation(client, next.id);

    if (
      next.status_code === PROVIDER_STATUS.PENDING_PROFILE &&
      verification &&
      verification.status_code === VERIFICATION_STATUS.PENDING &&
      next.name &&
      next.category_id
    ) {
      const pending = await getStatus(ENTITY.PROVIDER, PROVIDER_STATUS.PENDING_VERIFICATION);
      await client.query(`UPDATE providers SET status_id = $2, status_reason = NULL WHERE id = $1`, [
        next.id,
        pending.id,
      ]);
      await recordStatusChange(client, {
        providerId: next.id,
        fromStatusId: next.status_id,
        toStatusId: pending.id,
        reason: "Profile completed",
      });
      next = await fetchProviderById(client, next.id);
    }

    return serializeProvider(next, {
      location: serializeLocation(location),
      verification: serializeVerification(verification),
    });
  });
}

export async function submitVerification(provider, { documentType, documentUrl }) {
  if (provider.status_code === PROVIDER_STATUS.SUSPENDED) {
    throw new AppError(403, "Suspended providers cannot submit documents", "PROVIDER_SUSPENDED");
  }
  if (!provider.name || !provider.category_id) {
    throw new AppError(400, "Complete your profile before uploading a document", "PROFILE_INCOMPLETE");
  }
  if (!documentUrl) {
    throw new AppError(400, "Verification document is required", "DOCUMENT_REQUIRED");
  }

  return withTransaction(async (client) => {
    const pendingVerification = await getStatus(ENTITY.VERIFICATION, VERIFICATION_STATUS.PENDING);
    const pendingProvider = await getStatus(ENTITY.PROVIDER, PROVIDER_STATUS.PENDING_VERIFICATION);

    const inserted = await client.query(
      `INSERT INTO verifications (provider_id, document_type, document_url, status_id)
       VALUES ($1, $2, $3, $4)
       RETURNING *`,
      [provider.id, documentType, documentUrl, pendingVerification.id],
    );

    const current = await fetchProviderById(client, provider.id);
    if (
      [PROVIDER_STATUS.PENDING_PROFILE, PROVIDER_STATUS.REJECTED].includes(current.status_code)
    ) {
      await client.query(
        `UPDATE providers SET status_id = $2, status_reason = NULL WHERE id = $1`,
        [provider.id, pendingProvider.id],
      );
      await recordStatusChange(client, {
        providerId: provider.id,
        fromStatusId: current.status_id,
        toStatusId: pendingProvider.id,
        reason: "Verification document submitted",
      });
    }

    const next = await fetchProviderById(client, provider.id);
    const location = await fetchLocation(client, provider.id);
    return serializeProvider(next, {
      location: serializeLocation(location),
      verification: serializeVerification({
        ...inserted.rows[0],
        status_code: VERIFICATION_STATUS.PENDING,
      }),
    });
  });
}

export async function listEnabledCategories() {
  const { rows } = await query(
    `SELECT * FROM categories WHERE is_enabled = true ORDER BY name`,
  );
  return rows;
}
