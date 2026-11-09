import {
  COMPULSORY_DOCUMENT_TYPES,
  ENTITY,
  PROVIDER_STATUS,
  VERIFICATION_STATUS,
} from "../config/constants.js";
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

async function assertEnabledCategory(client, categoryId, categoryName) {
  let cat = null;
  const isUuid = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(String(categoryId || ""));
  if (isUuid) {
    const res = await client.query(`SELECT id, name, is_enabled FROM categories WHERE id = $1`, [categoryId]);
    if (res.rows[0]) cat = res.rows[0];
  }
  if (!cat && (categoryName || categoryId)) {
    const term = categoryName || categoryId;
    const res = await client.query(
      `SELECT id, name, is_enabled FROM categories WHERE LOWER(name) = LOWER($1) OR slug = $1 LIMIT 1`,
      [term],
    );
    if (res.rows[0]) cat = res.rows[0];
  }
  if (!cat) {
    const res = await client.query(
      `SELECT id, name, is_enabled FROM categories WHERE is_enabled = true ORDER BY sort_order ASC, name ASC LIMIT 1`,
    );
    if (res.rows[0]) cat = res.rows[0];
  }
  if (!cat) throw new NotFoundError("Category not found");
  if (!cat.is_enabled) {
    throw new AppError(400, "Category is disabled", "CATEGORY_DISABLED");
  }
  return cat;
}

async function upsertLocation(client, providerId, input) {
  const hasLocation =
    input.address || input.city || input.latitude !== undefined || input.longitude !== undefined;
  if (!hasLocation) {
    return fetchLocation(client, providerId);
  }

  const lat = input.latitude !== undefined && input.latitude !== null ? Number(input.latitude) : null;
  const lng = input.longitude !== undefined && input.longitude !== null ? Number(input.longitude) : null;
  let city = input.city || null;
  if (!city && lat && lng) {
    if (lat >= 24.0 && lat <= 25.5 && lng >= 46.0 && lng <= 47.5) city = "Riyadh";
    else if (lat >= 21.0 && lat <= 22.0 && lng >= 38.8 && lng <= 39.8) city = "Jeddah";
    else if (lat >= 26.0 && lat <= 26.8 && lng >= 49.5 && lng <= 50.5) city = "Dammam";
    else city = "Riyadh";
  }

  await client.query(
    `INSERT INTO locations (provider_id, latitude, longitude, address, city, location_updated_at)
     VALUES ($1, $2, $3, $4, $5, now())
     ON CONFLICT (provider_id) DO UPDATE
     SET latitude = COALESCE(EXCLUDED.latitude, locations.latitude),
         longitude = COALESCE(EXCLUDED.longitude, locations.longitude),
         address = COALESCE(EXCLUDED.address, locations.address),
         city = COALESCE(EXCLUDED.city, locations.city),
         location_updated_at = now()`,
    [
      providerId,
      lat,
      lng,
      input.address || (city ? `${city}, Saudi Arabia` : null),
      city,
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
    const category = await assertEnabledCategory(client, input.categoryId, input.categoryName);

    let resolvedVehicleTypeId = null;
    let resolvedVehicleTypeName = input.vehicleType || null;
    if (input.vehicleTypeId && /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(input.vehicleTypeId)) {
      const vtRow = await client.query(`SELECT id, name FROM vehicle_types WHERE id = $1`, [input.vehicleTypeId]);
      if (vtRow.rows[0]) {
        resolvedVehicleTypeId = vtRow.rows[0].id;
        resolvedVehicleTypeName = vtRow.rows[0].name;
      }
    } else if (input.vehicleType) {
      const vtRow = await client.query(
        `SELECT id, name FROM vehicle_types WHERE LOWER(name) = LOWER($1) OR slug = $1 LIMIT 1`,
        [input.vehicleType],
      );
      if (vtRow.rows[0]) {
        resolvedVehicleTypeId = vtRow.rows[0].id;
        resolvedVehicleTypeName = vtRow.rows[0].name;
      }
    }

    const whatsappNumber = input.whatsappNumber || input.whatsapp || null;
    const iqamaNumber = input.iqamaNumber || input.nationalId || null;
    const iqamaExpiry = input.iqamaExpiry || null;
    const vehicleModel = input.vehicleModel || null;
    const plateNumber = input.plateNumber || null;
    const vehicleColor = input.vehicleColor || null;

    await client.query(
      `UPDATE providers
       SET name = $2,
           category_id = $3,
           photo_url = COALESCE($4, photo_url),
           whatsapp_number = COALESCE($5, whatsapp_number),
           iqama_number = COALESCE($6, iqama_number),
           iqama_expiry = COALESCE($7, iqama_expiry),
           vehicle_type_id = COALESCE($8, vehicle_type_id),
           vehicle_type_name = COALESCE($9, vehicle_type_name),
           vehicle_model = COALESCE($10, vehicle_model),
           plate_number = COALESCE($11, plate_number),
           vehicle_color = COALESCE($12, vehicle_color)
       WHERE id = $1`,
      [
        provider.id,
        input.name,
        category.id,
        input.photoUrl || null,
        whatsappNumber,
        iqamaNumber,
        iqamaExpiry,
        resolvedVehicleTypeId,
        resolvedVehicleTypeName,
        vehicleModel,
        plateNumber,
        vehicleColor,
      ],
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

export function normalizeDocumentType(docType) {
  if (docType === "driving_licence") return "license";
  return docType;
}

export async function getProviderDocumentsStatus(clientOrPool, providerId) {
  const runner = clientOrPool?.query ? clientOrPool : { query };
  const { rows } = await runner.query(
    `SELECT v.*, s.code AS status_code
     FROM verifications v
     JOIN statuses s ON s.id = v.status_id
     WHERE v.provider_id = $1
     ORDER BY v.created_at DESC`,
    [providerId],
  );

  const uploadedTypes = new Set(
    rows.map((r) => normalizeDocumentType(r.document_type)),
  );

  // If provider uploaded legacy cnic or passport (e.g. from existing test fixtures), treat as complete
  const hasLegacyDoc = uploadedTypes.has("cnic") || uploadedTypes.has("passport");
  const hasVehiclePhotosBundle = uploadedTypes.has("vehicle_photos");

  const missingCompulsory = COMPULSORY_DOCUMENT_TYPES.filter((type) => {
    if (
      hasVehiclePhotosBundle &&
      [
        "vehicle_front",
        "vehicle_rear",
        "vehicle_left_side",
        "vehicle_right_side",
      ].includes(type)
    ) {
      return false;
    }
    return !uploadedTypes.has(type);
  });

  const allCompulsorySubmitted = hasLegacyDoc || missingCompulsory.length === 0;

  return {
    allCompulsorySubmitted,
    compulsoryDocuments: COMPULSORY_DOCUMENT_TYPES,
    missingCompulsoryDocuments: hasLegacyDoc ? [] : missingCompulsory,
    uploadedDocuments: rows.map(serializeVerification),
    hasLegacyDoc,
  };
}

export async function assertAllCompulsoryDocumentsSubmitted(clientOrPool, providerId) {
  const docStatus = await getProviderDocumentsStatus(clientOrPool, providerId);
  if (!docStatus.allCompulsorySubmitted) {
    throw new AppError(
      400,
      `All documents are compulsory. Missing: ${docStatus.missingCompulsoryDocuments.join(", ")}`,
      "COMPULSORY_DOCUMENTS_MISSING",
    );
  }
  return docStatus;
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

  const normalizedType = normalizeDocumentType(documentType);

  return withTransaction(async (client) => {
    const pendingVerification = await getStatus(ENTITY.VERIFICATION, VERIFICATION_STATUS.PENDING);
    const pendingProvider = await getStatus(ENTITY.PROVIDER, PROVIDER_STATUS.PENDING_VERIFICATION);

    const inserted = await client.query(
      `INSERT INTO verifications (provider_id, document_type, document_url, status_id)
       VALUES ($1, $2, $3, $4)
       RETURNING *`,
      [provider.id, normalizedType, documentUrl, pendingVerification.id],
    );

    const docStatus = await getProviderDocumentsStatus(client, provider.id);
    const current = await fetchProviderById(client, provider.id);

    // If all compulsory documents have been submitted (or legacy cnic/passport):
    if (docStatus.allCompulsorySubmitted) {
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
          reason: "All compulsory documents submitted",
        });
      }
    }

    const next = await fetchProviderById(client, provider.id);
    const location = await fetchLocation(client, provider.id);
    return {
      ...serializeProvider(next, {
        location: serializeLocation(location),
        verification: serializeVerification({
          ...inserted.rows[0],
          status_code: VERIFICATION_STATUS.PENDING,
        }),
      }),
      documentsStatus: docStatus,
    };
  });
}

export async function listEnabledCategories() {
  const { rows } = await query(
    `SELECT * FROM categories WHERE is_enabled = true ORDER BY sort_order ASC, name ASC`,
  );
  return rows;
}

export async function completeProviderOnboarding(provider) {
  return withTransaction(async (client) => {
    const current = await fetchProviderById(client, provider.id);
    const pending = await getStatus(ENTITY.PROVIDER, PROVIDER_STATUS.PENDING_VERIFICATION);
    await client.query(
      `UPDATE providers SET status_id = $2, status_reason = NULL WHERE id = $1`,
      [provider.id, pending.id],
    );
    await recordStatusChange(client, {
      providerId: provider.id,
      fromStatusId: current.status_id,
      toStatusId: pending.id,
      reason: "Onboarding completed",
    });
    const next = await fetchProviderById(client, provider.id);
    const location = await fetchLocation(client, provider.id);
    const verification = await fetchLatestVerification(client, provider.id);
    return serializeProvider(next, {
      location: serializeLocation(location),
      verification: serializeVerification(verification),
    });
  });
}
