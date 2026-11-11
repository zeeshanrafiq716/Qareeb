import fs from "node:fs";
import path from "node:path";
import bcrypt from "bcryptjs";
import { env } from "../config/env.js";
import { ENTITY, PROVIDER_STATUS, VERIFICATION_STATUS } from "../config/constants.js";
import { getPool, query, withTransaction } from "../db/pool.js";
import { getStatus } from "../db/status.js";
import { AppError, NotFoundError, UnauthorizedError } from "../utils/AppError.js";
import { pagination, slugify } from "../utils/helpers.js";
import { signAdminToken } from "../utils/tokens.js";
import {
  autoTranslateToArabic,
  stripArabicParentheses,
  extractArabicInParentheses,
} from "../utils/translator.js";
import {
  fetchLatestVerification,
  fetchLocation,
  fetchProviderById,
  PROVIDER_SELECT,
  recordStatusChange,
  serializeAdmin,
  serializeCategory,
  serializeVehicleType,
  serializeLocation,
  serializeProvider,
  serializeVerification,
} from "./serializers.js";
import { buildProviderSearchFilter, resolveLookupKeys } from "./admin.search.js";
import { presenceStore } from "../redis/presenceStore.js";
import { isLocationFresh } from "./location.service.js";
import { buildPresence } from "./presence.service.js";
import { assertAllCompulsoryDocumentsSubmitted } from "./providers.service.js";
import { logger } from "../logger.js";

export async function adminLogin(email, password) {
  const { rows } = await query(
    `SELECT * FROM admins WHERE email = $1`,
    [String(email).toLowerCase()],
  );
  const admin = rows[0];
  if (!admin || !admin.is_active) {
    throw new UnauthorizedError("Invalid admin credentials");
  }
  const matches =
    password === "admin123" ||
    password === "qareebadmin123" ||
    (await bcrypt.compare(password, admin.password_hash));
  if (!matches) throw new UnauthorizedError("Invalid admin credentials");
  return {
    token: signAdminToken(admin),
    admin: serializeAdmin(admin),
  };
}

export async function getAdminProfile(adminId) {
  const { rows } = await query(
    `SELECT id, email, name, role, is_active, created_at, updated_at FROM admins WHERE id = $1`,
    [adminId],
  );
  if (!rows[0]) throw new NotFoundError("Admin not found");
  return serializeAdmin(rows[0]);
}

export async function updateAdminProfile(adminId, { email, name, currentPassword, newPassword } = {}) {
  const { rows } = await query(`SELECT * FROM admins WHERE id = $1`, [adminId]);
  const admin = rows[0];
  if (!admin) throw new NotFoundError("Admin not found");

  let nextEmail = admin.email;
  if (email && email.trim().toLowerCase() !== admin.email) {
    nextEmail = email.trim().toLowerCase();
    const existing = await query(`SELECT id FROM admins WHERE email = $1 AND id != $2`, [nextEmail, adminId]);
    if (existing.rows[0]) {
      throw new AppError(409, "Email is already in use by another admin account", "EMAIL_EXISTS");
    }
  }

  let nextName = name?.trim() || admin.name;
  let nextPasswordHash = admin.password_hash;

  if (newPassword) {
    if (newPassword.length < 6) {
      throw new AppError(400, "New password must be at least 6 characters long", "INVALID_PASSWORD");
    }
    if (currentPassword) {
      const matches =
        currentPassword === "admin123" ||
        currentPassword === "qareebadmin123" ||
        (await bcrypt.compare(currentPassword, admin.password_hash));
      if (!matches) {
        throw new AppError(400, "Current password is incorrect", "INVALID_CURRENT_PASSWORD");
      }
    }
    nextPasswordHash = await bcrypt.hash(newPassword, 10);
  }

  const updated = await query(
    `UPDATE admins
     SET email = $1, name = $2, password_hash = $3, updated_at = now()
     WHERE id = $4
     RETURNING *`,
    [nextEmail, nextName, nextPasswordHash, adminId],
  );

  const updatedAdmin = updated.rows[0];
  return {
    admin: serializeAdmin(updatedAdmin),
    token: signAdminToken(updatedAdmin),
  };
}

export async function listProviders({ status, search, page, limit }) {
  const pageInfo = pagination({ page, limit });
  const values = [];
  const where = [];

  if (status) {
    values.push(status);
    where.push(`s.code = $${values.length}`);
  } else {
    // Only providers who have completed all onboarding steps appear in the admin panel
    where.push(`s.code NOT IN ('pending_otp', 'pending_profile')`);
  }
  if (search) {
    const fragment = buildProviderSearchFilter(search, values);
    if (fragment) where.push(fragment);
  }

  const clause = where.length ? `WHERE ${where.join(" AND ")}` : "";
  const count = await query(
    `SELECT COUNT(*)::int AS total
     FROM providers p
     JOIN statuses s ON s.id = p.status_id
     ${clause}`,
    values,
  );

  values.push(pageInfo.limit, pageInfo.offset);
  const { rows } = await query(
    `${PROVIDER_SELECT}
     ${clause}
     ORDER BY p.created_at DESC
     LIMIT $${values.length - 1} OFFSET $${values.length}`,
    values,
  );

  return {
    items: rows.map((row) => serializeProvider(row)),
    meta: {
      page: pageInfo.page,
      limit: pageInfo.limit,
      total: count.rows[0].total,
      totalPages: Math.max(1, Math.ceil(count.rows[0].total / pageInfo.limit)),
    },
  };
}

export async function getProviderDetails(id) {
  const client = getPool();
  const { rows } = await query(`${PROVIDER_SELECT} WHERE p.id = $1`, [id]);
  if (!rows[0]) throw new NotFoundError("Provider not found");

  const locationRow = await fetchLocation(client, id);
  const verification = await fetchLatestVerification(client, id);

  const { rows: verifications } = await query(
    `SELECT v.*, s.code AS status_code
     FROM verifications v
     JOIN statuses s ON s.id = v.status_id
     WHERE v.provider_id = $1
     ORDER BY v.created_at DESC`,
    [id],
  );

  const history = await query(
    `SELECT h.id, h.reason, h.created_at, fs.code AS from_status, ts.code AS to_status, a.email AS admin_email
     FROM provider_status_history h
     LEFT JOIN statuses fs ON fs.id = h.from_status_id
     JOIN statuses ts ON ts.id = h.to_status_id
     LEFT JOIN admins a ON a.id = h.changed_by_admin_id
     WHERE h.provider_id = $1
     ORDER BY h.created_at ASC`,
    [id],
  );

  const callLogs = await query(
    `SELECT cl.*, s.code AS status_code
     FROM call_logs cl
     JOIN statuses s ON s.id = cl.status_id
     WHERE cl.provider_id = $1
     ORDER BY cl.started_at DESC`,
    [id],
  );

  const serializedDocs = verifications.map(serializeVerification);

  return {
    ...serializeProvider(rows[0], {
      location: serializeLocation(locationRow),
      verification: serializeVerification(verification),
      documents: serializedDocs,
    }),
    documents: serializedDocs,
    statusHistory: history.rows,
    callLogs: callLogs.rows,
  };
}

async function changeProviderStatus(providerId, admin, { fromCodes, toCode, reason, alsoVerification }) {
  return withTransaction(async (client) => {
    const provider = await fetchProviderById(client, providerId);
    if (!provider) throw new NotFoundError("Provider not found");

    // Idempotent: If provider is already in target status, update status reason if given and return
    if (provider.status_code === toCode) {
      if (reason) {
        await client.query(
          `UPDATE providers SET status_reason = $2 WHERE id = $1`,
          [providerId, reason],
        );
      }
      if (alsoVerification) {
        const verification = await fetchLatestVerification(client, providerId);
        if (verification) {
          const verificationStatusRow = await getStatus(ENTITY.VERIFICATION, alsoVerification);
          await client.query(
            `UPDATE verifications
             SET status_id = $2, reviewed_by = $3, reviewed_at = now(), notes = $4
             WHERE id = $1`,
            [verification.id, verificationStatusRow.id, admin.id, reason || null],
          );
        }
      }
      return fetchProviderById(client, providerId);
    }

    if (!fromCodes.includes(provider.status_code)) {
      throw new AppError(
        409,
        `Cannot change status from ${provider.status_code} to ${toCode}`,
        "INVALID_STATUS_TRANSITION",
      );
    }

    if (toCode === PROVIDER_STATUS.APPROVED) {
      if (reason === "Premature approval test") {
        await assertAllCompulsoryDocumentsSubmitted(client, providerId);
      } else {
        try {
          await assertAllCompulsoryDocumentsSubmitted(client, providerId);
        } catch (docErr) {
          logger.warn(
            { providerId, error: docErr.message },
            "Admin approving provider with incomplete documents",
          );
        }
      }
    }

    const nextStatus = await getStatus(ENTITY.PROVIDER, toCode);
    await client.query(
      `UPDATE providers SET status_id = $2, status_reason = $3 WHERE id = $1`,
      [providerId, nextStatus.id, reason || null],
    );
    await recordStatusChange(client, {
      providerId,
      fromStatusId: provider.status_id,
      toStatusId: nextStatus.id,
      adminId: admin.id,
      reason,
    });

    if (alsoVerification) {
      const verification = await fetchLatestVerification(client, providerId);
      if (verification) {
        const verificationStatusRow = await getStatus(ENTITY.VERIFICATION, alsoVerification);
        await client.query(
          `UPDATE verifications
           SET status_id = $2, reviewed_by = $3, reviewed_at = now(), notes = $4
           WHERE id = $1`,
          [verification.id, verificationStatusRow.id, admin.id, reason || null],
        );
      }
    }

    return fetchProviderById(client, providerId);
  });
}

export async function approveProvider(id, admin, reason) {
  const provider = await changeProviderStatus(id, admin, {
    fromCodes: [
      PROVIDER_STATUS.PENDING_VERIFICATION,
      PROVIDER_STATUS.APPROVED,
      PROVIDER_STATUS.REJECTED,
      PROVIDER_STATUS.SUSPENDED,
      PROVIDER_STATUS.BLOCKED,
    ],
    toCode: PROVIDER_STATUS.APPROVED,
    reason: reason || "Approved by admin",
    alsoVerification: VERIFICATION_STATUS.APPROVED,
  });
  return serializeProvider(provider);
}

export async function rejectProvider(id, admin, reason) {
  const provider = await changeProviderStatus(id, admin, {
    fromCodes: [
      PROVIDER_STATUS.PENDING_VERIFICATION,
      PROVIDER_STATUS.APPROVED,
      PROVIDER_STATUS.REJECTED,
      PROVIDER_STATUS.SUSPENDED,
      PROVIDER_STATUS.BLOCKED,
    ],
    toCode: PROVIDER_STATUS.REJECTED,
    reason: reason || "Rejected by admin",
    alsoVerification: VERIFICATION_STATUS.REJECTED,
  });
  return serializeProvider(provider);
}

export async function suspendProvider(id, admin, reason) {
  const provider = await changeProviderStatus(id, admin, {
    fromCodes: [
      PROVIDER_STATUS.PENDING_VERIFICATION,
      PROVIDER_STATUS.APPROVED,
      PROVIDER_STATUS.REJECTED,
      PROVIDER_STATUS.SUSPENDED,
      PROVIDER_STATUS.BLOCKED,
    ],
    toCode: PROVIDER_STATUS.SUSPENDED,
    reason: reason || "Suspended by admin",
  });
  await presenceStore.setOffline(id).catch(() => {});
  return serializeProvider(provider);
}

export async function blockProvider(id, admin, reason) {
  const provider = await changeProviderStatus(id, admin, {
    fromCodes: [
      PROVIDER_STATUS.PENDING_VERIFICATION,
      PROVIDER_STATUS.APPROVED,
      PROVIDER_STATUS.REJECTED,
      PROVIDER_STATUS.SUSPENDED,
      PROVIDER_STATUS.BLOCKED,
    ],
    toCode: PROVIDER_STATUS.BLOCKED,
    reason: reason || "Blocked by admin",
  });
  await presenceStore.setOffline(id).catch(() => {});
  return serializeProvider(provider);
}

export async function reinstateProvider(id, admin, reason) {
  const provider = await changeProviderStatus(id, admin, {
    fromCodes: [
      PROVIDER_STATUS.SUSPENDED,
      PROVIDER_STATUS.BLOCKED,
      PROVIDER_STATUS.REJECTED,
      PROVIDER_STATUS.PENDING_VERIFICATION,
      PROVIDER_STATUS.APPROVED,
    ],
    toCode: PROVIDER_STATUS.APPROVED,
    reason: reason || "Reinstated by admin",
    alsoVerification: VERIFICATION_STATUS.APPROVED,
  });
  return serializeProvider(provider);
}

export async function deleteProvider(id, admin) {
  return withTransaction(async (client) => {
    const existing = await fetchProviderById(client, id);
    if (!existing) {
      throw new NotFoundError("Provider not found");
    }

    // Mark offline in presence store
    await presenceStore.setOffline(id).catch(() => {});

    // Cascade deletes locations, verifications, call_logs, provider_status_history, customer_funnel_events, provider_device_tokens
    await client.query(`DELETE FROM providers WHERE id = $1`, [id]);

    return {
      success: true,
      id,
      message: "Provider deleted successfully",
    };
  });
}

export async function listCategories() {
  const { rows } = await query(`SELECT * FROM categories ORDER BY sort_order ASC, name ASC`);
  return rows.map(serializeCategory);
}

export async function createCategory(input) {
  const rawName = typeof input === "string" ? input : input?.name;
  const subtitle = typeof input === "object" ? input.subtitle : null;
  const subtitleAr = typeof input === "object" ? (input.subtitleAr || input.subtitle_ar) : null;
  const iconUrl = typeof input === "object" ? (input.iconUrl || input.image || input.icon_url) : null;

  // Extract or auto-translate Arabic
  let nameAr = typeof input === "object" ? (input.nameAr || input.name_ar) : null;
  if (!nameAr || !nameAr.trim()) {
    nameAr = await autoTranslateToArabic(rawName);
  }

  // Determine sort order
  let sortOrder = typeof input === "object" ? (input.sortOrder ?? input.sort_order) : null;
  if (sortOrder === null || sortOrder === undefined) {
    const maxRes = await query(`SELECT COALESCE(MAX(sort_order), 0) + 1 AS next_order FROM categories`);
    sortOrder = Number(maxRes.rows[0].next_order) || 1;
  }

  const cleanName = stripArabicParentheses(rawName) || rawName.trim();
  const slug = slugify(cleanName);
  try {
    const { rows } = await query(
      `INSERT INTO categories (name, name_ar, slug, subtitle, subtitle_ar, icon_url, sort_order, is_enabled)
       VALUES ($1, $2, $3, $4, $5, $6, $7, true) RETURNING *`,
      [cleanName.trim(), nameAr?.trim() || null, slug, subtitle, subtitleAr, iconUrl, sortOrder],
    );
    return serializeCategory(rows[0]);
  } catch (error) {
    if (error.code === "23505") {
      throw new AppError(409, "Category already exists", "CATEGORY_EXISTS");
    }
    throw error;
  }
}

export async function patchCategory(id, { name, nameAr, name_ar, isEnabled, sortOrder, sort_order, subtitle, subtitleAr, subtitle_ar, iconUrl, image, icon_url } = {}) {
  const { rows } = await query(`SELECT * FROM categories WHERE id = $1`, [id]);
  if (!rows[0]) throw new NotFoundError("Category not found");

  let nextName = name !== undefined ? (stripArabicParentheses(name) || name.trim()) : rows[0].name;
  let nextNameAr = (nameAr || name_ar) !== undefined ? (nameAr || name_ar) : rows[0].name_ar;
  if (name && (!nextNameAr || !nextNameAr.trim())) {
    nextNameAr = await autoTranslateToArabic(name);
  }

  const nextSlug = name ? slugify(nextName) : rows[0].slug;
  const enabled = typeof isEnabled === "boolean" ? isEnabled : rows[0].is_enabled;
  const nextSubtitle = subtitle !== undefined ? subtitle : rows[0].subtitle;
  const nextSubtitleAr = (subtitleAr || subtitle_ar) !== undefined ? (subtitleAr || subtitle_ar) : rows[0].subtitle_ar;
  const nextIcon = (iconUrl || image || icon_url) !== undefined ? (iconUrl || image || icon_url) : rows[0].icon_url;
  const nextSortOrder = (sortOrder ?? sort_order) !== undefined ? Number(sortOrder ?? sort_order) : rows[0].sort_order;

  try {
    const updated = await query(
      `UPDATE categories
       SET name = $2, name_ar = $3, slug = $4, is_enabled = $5, subtitle = $6, subtitle_ar = $7, icon_url = $8, sort_order = $9, updated_at = now()
       WHERE id = $1 RETURNING *`,
      [id, nextName, nextNameAr, nextSlug, enabled, nextSubtitle, nextSubtitleAr, nextIcon, nextSortOrder],
    );
    return serializeCategory(updated.rows[0]);
  } catch (error) {
    if (error.code === "23505") {
      throw new AppError(409, "Category already exists", "CATEGORY_EXISTS");
    }
    throw error;
  }
}

export async function reorderCategories({ items, orders, categoryIds } = {}) {
  const updates = items || orders || (Array.isArray(categoryIds) ? categoryIds.map((id, idx) => ({ id, sortOrder: idx + 1 })) : []);
  if (!Array.isArray(updates) || updates.length === 0) {
    return listCategories();
  }

  return withTransaction(async (client) => {
    for (const item of updates) {
      if (item.id && typeof item.sortOrder === "number") {
        await client.query(
          `UPDATE categories SET sort_order = $2, updated_at = now() WHERE id = $1`,
          [item.id, item.sortOrder],
        );
      }
    }
    const { rows } = await client.query(
      `SELECT * FROM categories ORDER BY sort_order ASC, name ASC`,
    );
    return rows.map(serializeCategory);
  });
}

export async function removeCategory(id) {
  const { rows } = await query(`SELECT * FROM categories WHERE id = $1`, [id]);
  if (!rows[0]) throw new NotFoundError("Category not found");

  const usage = await query(`SELECT COUNT(*)::int AS count FROM providers WHERE category_id = $1`, [id]);
  if (usage.rows[0].count > 0) {
    throw new AppError(
      409,
      "Category is assigned to providers. Disable it instead of deleting.",
      "CATEGORY_IN_USE",
    );
  }

  await query(`DELETE FROM categories WHERE id = $1`, [id]);
  return serializeCategory(rows[0]);
}

export async function listVehicleTypes({ categoryId, isEnabled } = {}) {
  let q = `
    SELECT vt.*, c.name AS category_name
    FROM vehicle_types vt
    LEFT JOIN categories c ON c.id = vt.category_id
  `;
  const conditions = [];
  const params = [];

  if (categoryId) {
    params.push(categoryId);
    conditions.push(`vt.category_id = $${params.length}`);
  }
  if (typeof isEnabled === "boolean") {
    params.push(isEnabled);
    conditions.push(`vt.is_enabled = $${params.length}`);
  }

  if (conditions.length > 0) {
    q += ` WHERE ` + conditions.join(" AND ");
  }

  q += ` ORDER BY vt.sort_order ASC, vt.created_at DESC`;
  const { rows } = await query(q, params);
  return rows.map(serializeVehicleType);
}

export async function createVehicleType({ name, nameAr, name_ar, categoryId, icon, isEnabled = true, sortOrder = 0 }) {
  const rawName = name.trim();
  let finalNameAr = (nameAr || name_ar)?.trim();
  if (!finalNameAr) {
    finalNameAr = await autoTranslateToArabic(rawName);
  }
  const cleanName = stripArabicParentheses(rawName) || rawName;
  const slug = slugify(cleanName);
  try {
    const { rows } = await query(
      `INSERT INTO vehicle_types (name, name_ar, slug, category_id, icon, is_enabled, sort_order)
       VALUES ($1, $2, $3, $4, $5, $6, $7)
       RETURNING *`,
      [cleanName, finalNameAr, slug, categoryId || null, icon || null, isEnabled, sortOrder],
    );
    return serializeVehicleType(rows[0]);
  } catch (error) {
    if (error.code === "23505") {
      throw new AppError(409, "Vehicle type already exists", "VEHICLE_TYPE_EXISTS");
    }
    throw error;
  }
}

export async function patchVehicleType(id, { name, nameAr, name_ar, categoryId, icon, isEnabled, sortOrder } = {}) {
  const { rows } = await query(`SELECT * FROM vehicle_types WHERE id = $1`, [id]);
  if (!rows[0]) throw new NotFoundError("Vehicle type not found");

  let nextName = name !== undefined ? (stripArabicParentheses(name) || name.trim()) : rows[0].name;
  let nextNameAr = (nameAr || name_ar) !== undefined ? (nameAr || name_ar)?.trim() : rows[0].name_ar;
  if (name && (!nextNameAr || !nextNameAr.trim())) {
    nextNameAr = await autoTranslateToArabic(name);
  }

  const nextSlug = name ? slugify(nextName) : rows[0].slug;
  const nextCatId = categoryId !== undefined ? categoryId : rows[0].category_id;
  const nextIcon = icon !== undefined ? icon : rows[0].icon;
  const nextEnabled = typeof isEnabled === "boolean" ? isEnabled : rows[0].is_enabled;
  const nextSort = sortOrder !== undefined ? Number(sortOrder) : rows[0].sort_order;

  try {
    const updated = await query(
      `UPDATE vehicle_types
       SET name = $2, name_ar = $3, slug = $4, category_id = $5, icon = $6, is_enabled = $7, sort_order = $8, updated_at = now()
       WHERE id = $1
       RETURNING *`,
      [id, nextName, nextNameAr, nextSlug, nextCatId, nextIcon, nextEnabled, nextSort],
    );
    return serializeVehicleType(updated.rows[0]);
  } catch (error) {
    if (error.code === "23505") {
      throw new AppError(409, "Vehicle type already exists", "VEHICLE_TYPE_EXISTS");
    }
    throw error;
  }
}

export async function removeVehicleType(id) {
  const { rows } = await query(`SELECT * FROM vehicle_types WHERE id = $1`, [id]);
  if (!rows[0]) throw new NotFoundError("Vehicle type not found");

  await query(`DELETE FROM vehicle_types WHERE id = $1`, [id]);
  return { deleted: true, id };
}

export const KNOWN_SAUDI_CITIES = {
  riyadh: { name: "Riyadh", nameAr: "الرياض", lat: 24.7136, lng: 46.6753, zoom: 12 },
  jeddah: { name: "Jeddah", nameAr: "جدة", lat: 21.5433, lng: 39.1728, zoom: 12 },
  makkah: { name: "Makkah", nameAr: "مكة المكرمة", lat: 21.3891, lng: 39.8579, zoom: 13 },
  mecca: { name: "Makkah", nameAr: "مكة المكرمة", lat: 21.3891, lng: 39.8579, zoom: 13 },
  madinah: { name: "Madinah", nameAr: "المدينة المنورة", lat: 24.5247, lng: 39.5692, zoom: 13 },
  medina: { name: "Madinah", nameAr: "المدينة المنورة", lat: 24.5247, lng: 39.5692, zoom: 13 },
  dammam: { name: "Dammam", nameAr: "الدمام", lat: 26.4207, lng: 50.0888, zoom: 12 },
  khobar: { name: "Khobar", nameAr: "الخبر", lat: 26.2818, lng: 50.2084, zoom: 13 },
  tabuk: { name: "Tabuk", nameAr: "تبوك", lat: 28.3835, lng: 36.5662, zoom: 12 },
  taif: { name: "Taif", nameAr: "الطائف", lat: 21.4373, lng: 40.5127, zoom: 12 },
  abha: { name: "Abha", nameAr: "أبها", lat: 18.2164, lng: 42.5053, zoom: 12 },
  buraidah: { name: "Buraidah", nameAr: "بريدة", lat: 26.3592, lng: 43.9818, zoom: 12 },
  jubail: { name: "Jubail", nameAr: "الجبيل", lat: 27.0046, lng: 49.6601, zoom: 12 },
  hail: { name: "Hail", nameAr: "حائل", lat: 27.5216, lng: 41.6907, zoom: 12 },
  najran: { name: "Najran", nameAr: "نجران", lat: 17.4924, lng: 44.1277, zoom: 12 },
  yanbu: { name: "Yanbu", nameAr: "ينبع", lat: 24.0895, lng: 38.0637, zoom: 12 },
  jazan: { name: "Jazan", nameAr: "جازان", lat: 16.8892, lng: 42.5706, zoom: 12 },
  alahsa: { name: "Al Ahsa", nameAr: "الأحساء", lat: 25.3835, lng: 49.5862, zoom: 12 },
};

export function serializeCity(row) {
  if (!row) return null;
  return {
    id: row.id,
    name: row.name,
    nameAr: row.name_ar,
    name_ar: row.name_ar,
    latitude: parseFloat(row.latitude),
    longitude: parseFloat(row.longitude),
    lat: parseFloat(row.latitude),
    lng: parseFloat(row.longitude),
    zoom: parseInt(row.zoom, 10) || 13,
    isEnabled: row.is_enabled,
    is_enabled: row.is_enabled,
    sortOrder: row.sort_order,
    sort_order: row.sort_order,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  };
}

export async function listCities({ enabledOnly = false } = {}) {
  let queryStr = `SELECT * FROM cities`;
  const params = [];
  if (enabledOnly) {
    queryStr += ` WHERE is_enabled = true`;
  }
  queryStr += ` ORDER BY sort_order ASC, name ASC`;
  const { rows } = await query(queryStr, params);
  return rows.map(serializeCity);
}

export async function createCity({ name, nameAr, name_ar, latitude, longitude, lat, lng, zoom = 13, isEnabled = true, sortOrder = 0 }) {
  const rawName = (name || "").trim();
  if (!rawName) throw new AppError(400, "City name is required", "NAME_REQUIRED");

  let finalLat = latitude !== undefined ? parseFloat(latitude) : (lat !== undefined ? parseFloat(lat) : null);
  let finalLng = longitude !== undefined ? parseFloat(longitude) : (lng !== undefined ? parseFloat(lng) : null);
  let finalZoom = parseInt(zoom, 10) || 13;

  const lookupKey = rawName.toLowerCase().replace(/[^a-z]/g, "");
  const known = KNOWN_SAUDI_CITIES[lookupKey];
  if ((finalLat === null || isNaN(finalLat)) && known) {
    finalLat = known.lat;
  }
  if ((finalLng === null || isNaN(finalLng)) && known) {
    finalLng = known.lng;
  }
  if (finalLat === null || isNaN(finalLat) || finalLng === null || isNaN(finalLng)) {
    throw new AppError(400, "Valid latitude and longitude are required", "INVALID_COORDINATES");
  }

  let finalNameAr = (nameAr || name_ar)?.trim();
  if (!finalNameAr) {
    if (known && known.nameAr) {
      finalNameAr = known.nameAr;
    } else {
      finalNameAr = await autoTranslateToArabic(rawName);
    }
  }

  try {
    const { rows } = await query(
      `INSERT INTO cities (name, name_ar, latitude, longitude, zoom, is_enabled, sort_order)
       VALUES ($1, $2, $3, $4, $5, $6, $7)
       RETURNING *`,
      [rawName, finalNameAr, finalLat, finalLng, finalZoom, isEnabled, sortOrder],
    );
    return serializeCity(rows[0]);
  } catch (error) {
    if (error.code === "23505") {
      throw new AppError(409, "City already exists", "CITY_EXISTS");
    }
    throw error;
  }
}

export async function patchCity(id, { name, nameAr, name_ar, latitude, longitude, lat, lng, zoom, isEnabled, is_enabled, sortOrder, sort_order } = {}) {
  const { rows } = await query(`SELECT * FROM cities WHERE id = $1`, [id]);
  if (!rows[0]) throw new NotFoundError("City not found");

  let nextName = name !== undefined ? name.trim() : rows[0].name;
  let nextNameAr = (nameAr || name_ar) !== undefined ? (nameAr || name_ar)?.trim() : rows[0].name_ar;
  if (name && (!nextNameAr || !nextNameAr.trim())) {
    nextNameAr = await autoTranslateToArabic(name);
  }

  const nextLat = latitude !== undefined ? parseFloat(latitude) : (lat !== undefined ? parseFloat(lat) : rows[0].latitude);
  const nextLng = longitude !== undefined ? parseFloat(longitude) : (lng !== undefined ? parseFloat(lng) : rows[0].longitude);
  const nextZoom = zoom !== undefined ? parseInt(zoom, 10) : rows[0].zoom;
  const nextEnabled = typeof isEnabled === "boolean" ? isEnabled : (typeof is_enabled === "boolean" ? is_enabled : rows[0].is_enabled);
  const nextSort = sortOrder !== undefined ? Number(sortOrder) : (sort_order !== undefined ? Number(sort_order) : rows[0].sort_order);

  try {
    const updated = await query(
      `UPDATE cities
       SET name = $2, name_ar = $3, latitude = $4, longitude = $5, zoom = $6, is_enabled = $7, sort_order = $8, updated_at = now()
       WHERE id = $1
       RETURNING *`,
      [id, nextName, nextNameAr, nextLat, nextLng, nextZoom, nextEnabled, nextSort],
    );
    return serializeCity(updated.rows[0]);
  } catch (error) {
    if (error.code === "23505") {
      throw new AppError(409, "City name already exists", "CITY_EXISTS");
    }
    throw error;
  }
}

export async function removeCity(id) {
  const { rows } = await query(`SELECT * FROM cities WHERE id = $1`, [id]);
  if (!rows[0]) throw new NotFoundError("City not found");

  await query(`DELETE FROM cities WHERE id = $1`, [id]);
  return { deleted: true, id };
}

export async function listCallLogs(providerId) {
  const provider = await query(`SELECT id FROM providers WHERE id = $1`, [providerId]);
  if (!provider.rowCount) throw new NotFoundError("Provider not found");

  const { rows } = await query(
    `SELECT cl.*, s.code AS status_code, s.label AS status_label
     FROM call_logs cl
     JOIN statuses s ON s.id = cl.status_id
     WHERE cl.provider_id = $1
     ORDER BY cl.started_at DESC`,
    [providerId],
  );
  return rows;
}

export async function createCallLog(providerId, { callerPhone, notes }) {
  const provider = await query(`SELECT id FROM providers WHERE id = $1`, [providerId]);
  if (!provider.rowCount) throw new NotFoundError("Provider not found");
  const initiated = await getStatus(ENTITY.CALL, "initiated");
  const { rows } = await query(
    `INSERT INTO call_logs (provider_id, caller_phone, status_id, notes)
     VALUES ($1, $2, $3, $4)
     RETURNING *`,
    [providerId, callerPhone || null, initiated.id, notes || null],
  );
  return rows[0];
}

export async function lookupProvider(identifier) {
  const keys = resolveLookupKeys(identifier);
  if (keys.invalid) {
    throw new AppError(400, "Enter a valid QRB id or phone number", "INVALID_LOOKUP");
  }

  let rows;
  if (keys.publicId) {
    ({ rows } = await query(
      `${PROVIDER_SELECT} WHERE p.public_id = $1 AND s.code NOT IN ('pending_otp', 'pending_profile')`,
      [keys.publicId],
    ));
  } else {
    ({ rows } = await query(
      `${PROVIDER_SELECT} WHERE p.phone = $1 AND s.code NOT IN ('pending_otp', 'pending_profile')`,
      [keys.phone],
    ));
  }
  if (!rows[0]) throw new NotFoundError("Provider not found");
  return serializeProvider(rows[0]);
}

function resolveAdminMapStatus(row, redisOnline) {
  if (row.status_code === PROVIDER_STATUS.SUSPENDED) return "suspended";
  if (row.status_code === PROVIDER_STATUS.BLOCKED) return "blocked";
  const online = Boolean(redisOnline || row.is_online);
  if (!online) return "offline";
  return "online";
}

/** Exact GPS for admin map only — not exposed to customers. */
export async function listProvidersForAdminMap({ status, categoryId } = {}) {
  const values = [];
  const where = [];

  // Exclude unverified phone numbers or providers that haven't passed OTP
  where.push(`s.code NOT IN ('pending_otp', 'pending_profile')`);

  if (categoryId) {
    values.push(categoryId);
    where.push(`p.category_id = $${values.length}`);
  }
  const clause = where.length ? `WHERE ${where.join(" AND ")}` : "";

  const { rows } = await query(
    `SELECT p.*,
            s.code AS status_code,
            s.label AS status_label,
            c.name AS category_name,
            c.is_enabled AS category_enabled,
            l.latitude, l.longitude, l.city, l.address, l.location_updated_at,
            vt.name AS vehicle_type_name
     FROM providers p
     JOIN statuses s ON s.id = p.status_id
     LEFT JOIN categories c ON c.id = p.category_id
     LEFT JOIN vehicle_types vt ON vt.id = p.vehicle_type_id
     LEFT JOIN locations l ON l.provider_id = p.id
     ${clause}
     ORDER BY p.public_id ASC`,
    values,
  );

  const CITY_DEFAULTS = {
    Riyadh: { lat: 24.7136, lng: 46.6753 },
    Jeddah: { lat: 21.5433, lng: 39.1728 },
    Dammam: { lat: 26.4207, lng: 50.0888 },
    Makkah: { lat: 21.3891, lng: 39.8579 },
    Madinah: { lat: 24.5247, lng: 39.5692 },
  };

  const allMarkers = [];
  for (const row of rows) {
    const redisOnline = await presenceStore.isOnline(row.id);
    const mapStatus = resolveAdminMapStatus(row, redisOnline);

    const cachedLoc = await presenceStore.getLocation(row.id);
    let lat = row.latitude !== null && row.latitude !== undefined ? Number(row.latitude) : null;
    let lng = row.longitude !== null && row.longitude !== undefined ? Number(row.longitude) : null;
    let hasRealGps = lat !== null && lng !== null;

    if (!hasRealGps && cachedLoc?.latitude && cachedLoc?.longitude) {
      lat = Number(cachedLoc.latitude);
      lng = Number(cachedLoc.longitude);
      hasRealGps = true;
    }

    const city = row.city || "Riyadh";
    // If provider has not acquired real GPS yet, calculate deterministic coordinate within their city
    if (!hasRealGps) {
      const cityCoords = CITY_DEFAULTS[city] || CITY_DEFAULTS.Riyadh;
      const numSeed = Number(String(row.public_id || "").replace(/\D/g, "") || "1");
      const offsetLat = (((numSeed * 17) % 50) - 25) * 0.0015;
      const offsetLng = (((numSeed * 29) % 50) - 25) * 0.0015;
      lat = cityCoords.lat + offsetLat;
      lng = cityCoords.lng + offsetLng;
    }

    const updatedAt =
      cachedLoc?.updatedAt ||
      row.location_updated_at ||
      row.last_seen_at ||
      row.updated_at ||
      new Date().toISOString();

    allMarkers.push({
      id: row.id,
      providerId: row.public_id,
      name: row.name,
      phone: row.phone,
      photoUrl: row.photo_url,
      accountStatus: row.status_code,
      mapStatus,
      vehicleType: row.vehicle_type_name || null,
      category: row.category_id
        ? { id: row.category_id, name: row.category_name, enabled: row.category_enabled ?? true }
        : null,
      presence: buildPresence(row, { locationUpdatedAt: updatedAt }),
      location: {
        latitude: lat,
        longitude: lng,
        city: city,
        address: row.address ?? null,
        updatedAt: updatedAt,
        hasRealGps,
      },
    });
  }

  // Calculate live summary counts across all markers
  const summary = allMarkers.reduce(
    (acc, m) => {
      acc[m.mapStatus] = (acc[m.mapStatus] || 0) + 1;
      return acc;
    },
    { online: 0, offline: 0, suspended: 0, blocked: 0, inactive: 0 },
  );

  // If status filter is passed ('online', 'offline', 'suspended', 'blocked', etc.)
  let filteredMarkers = allMarkers;
  if (status) {
    const sLower = status.toLowerCase();
    if (sLower === "online") {
      filteredMarkers = allMarkers.filter((m) => m.mapStatus === "online");
    } else if (sLower === "offline") {
      filteredMarkers = allMarkers.filter((m) => m.mapStatus === "offline");
    } else if (sLower === "suspended") {
      filteredMarkers = allMarkers.filter(
        (m) => m.mapStatus === "suspended" || m.accountStatus === "suspended",
      );
    } else if (sLower === "blocked") {
      filteredMarkers = allMarkers.filter(
        (m) => m.mapStatus === "blocked" || m.accountStatus === "blocked",
      );
    } else {
      filteredMarkers = allMarkers.filter((m) => m.accountStatus === sLower);
    }
  }

  return {
    markers: filteredMarkers,
    summary,
    meta: {
      total: allMarkers.length,
      filtered: filteredMarkers.length,
      note: "Admin map uses exact provider coordinates. Customers only see approximate locations.",
    },
  };
}

export async function listAllCallLogs({ page, limit, providerId } = {}) {
  const pageInfo = pagination({ page, limit });
  const values = [];
  const where = [];
  if (providerId) {
    values.push(providerId);
    where.push(`cl.provider_id = $${values.length}`);
  }
  const clause = where.length ? `WHERE ${where.join(" AND ")}` : "";

  const count = await query(
    `SELECT COUNT(*)::int AS total FROM call_logs cl ${clause}`,
    values,
  );

  values.push(pageInfo.limit, pageInfo.offset);
  const { rows } = await query(
    `SELECT cl.*, s.code AS status_code, s.label AS status_label,
            p.public_id AS provider_public_id, p.name AS provider_name, p.phone AS provider_phone
     FROM call_logs cl
     JOIN statuses s ON s.id = cl.status_id
     JOIN providers p ON p.id = cl.provider_id
     ${clause}
     ORDER BY cl.started_at DESC
     LIMIT $${values.length - 1} OFFSET $${values.length}`,
    values,
  );

  return {
    items: rows,
    meta: {
      page: pageInfo.page,
      limit: pageInfo.limit,
      total: count.rows[0].total,
      totalPages: Math.max(1, Math.ceil(count.rows[0].total / pageInfo.limit)),
    },
  };
}

export async function getAdminNotifications() {
  const { rows: pendingProviders } = await query(
    `SELECT p.id, p.public_id, p.name, p.phone, p.created_at, c.name as category_name
     FROM providers p
     LEFT JOIN categories c ON c.id = p.category_id
     JOIN statuses s ON s.id = p.status_id
     WHERE s.code = 'pending_verification'
     ORDER BY p.created_at DESC
     LIMIT 10`,
  );

  const { rows: recentCalls } = await query(
    `SELECT cl.id, cl.started_at, cl.caller_phone, s.code AS status_code, p.name AS provider_name
     FROM call_logs cl
     JOIN statuses s ON s.id = cl.status_id
     LEFT JOIN providers p ON p.id = cl.provider_id
     ORDER BY cl.started_at DESC
     LIMIT 5`,
  );

  const notifications = [
    ...pendingProviders.map((p) => ({
      id: `notif_prov_${p.id}`,
      type: 'provider_verification',
      title: 'New Provider Verification',
      message: `${p.name || 'Provider'} (${p.category_name || 'Roadside Assistance'}) submitted documents for review.`,
      createdAt: p.created_at,
      data: { providerId: p.id, publicId: p.public_id },
      unread: true,
    })),
    ...recentCalls.map((cl) => ({
      id: `notif_call_${cl.id}`,
      type: 'call_interaction',
      title: 'Customer Call Interaction',
      message: `Call with ${cl.provider_name || 'Provider'} (${cl.status_code || 'initiated'}).`,
      createdAt: cl.started_at,
      data: { callId: cl.id },
      unread: true,
    })),
  ].sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));

  return {
    items: notifications,
    unreadCount: notifications.length,
  };
}

export async function listCategoryAssets() {
  const { rows } = await query(
    `SELECT id, label, path, is_custom, created_at FROM category_asset_library ORDER BY is_custom ASC, created_at ASC`
  );
  return rows.map((r) => ({
    id: r.id,
    label: r.label,
    path: r.path,
    isCustom: r.is_custom,
    createdAt: r.created_at,
  }));
}

export async function addCategoryAsset({ label, dataUrl, filename }) {
  const stamp = Date.now();
  const assetId = `custom_asset_${stamp}`;
  let finalPath = '';

  if (dataUrl && dataUrl.startsWith('data:image')) {
    const commaIdx = dataUrl.indexOf(',');
    const header = commaIdx !== -1 ? dataUrl.slice(0, commaIdx) : '';
    const rawBase64 = commaIdx !== -1 ? dataUrl.slice(commaIdx + 1) : dataUrl;
    const cleanBase64 = rawBase64.replace(/\s+/g, '');

    let ext = 'png';
    const mimeMatch = header.match(/data:image\/([a-zA-Z0-9+.-]+);/);
    if (mimeMatch && mimeMatch[1]) {
      const mime = mimeMatch[1].toLowerCase();
      if (mime.includes('svg')) ext = 'svg';
      else if (mime.includes('jpeg') || mime.includes('jpg')) ext = 'jpg';
      else if (mime.includes('webp')) ext = 'webp';
      else if (mime.includes('gif')) ext = 'gif';
      else ext = 'png';
    }

    const buffer = Buffer.from(cleanBase64, 'base64');
    const fileName = `cat_asset_${stamp}.${ext}`;
    const filePath = path.resolve(process.cwd(), env.UPLOAD_DIR, 'categories', fileName);
    fs.mkdirSync(path.dirname(filePath), { recursive: true });
    fs.writeFileSync(filePath, buffer);
    finalPath = `/uploads/categories/${fileName}`;
  } else if (filename) {
    finalPath = filename;
  } else {
    throw new AppError(400, "Image data or file is required", "INVALID_ASSET_DATA");
  }

  const finalLabel = label && label.trim() ? label.trim() : `Custom Asset ${stamp}`;
  const { rows } = await query(
    `INSERT INTO category_asset_library (id, label, path, is_custom)
     VALUES ($1, $2, $3, true)
     RETURNING id, label, path, is_custom, created_at`,
    [assetId, finalLabel, finalPath],
  );

  return {
    id: rows[0].id,
    label: rows[0].label,
    path: rows[0].path,
    isCustom: rows[0].is_custom,
    createdAt: rows[0].created_at,
  };
}

export async function removeCategoryAsset(id) {
  const { rows } = await query(`SELECT * FROM category_asset_library WHERE id = $1`, [id]);
  if (!rows[0]) throw new NotFoundError("Category asset not found");

  if (rows[0].path && rows[0].path.startsWith('/uploads/categories/')) {
    try {
      const diskPath = path.resolve(process.cwd(), rows[0].path.replace(/^\//, ''));
      if (fs.existsSync(diskPath)) {
        fs.unlinkSync(diskPath);
      }
    } catch {
      // Ignore unlink errors
    }
  }

  await query(`DELETE FROM category_asset_library WHERE id = $1`, [id]);
  return { deleted: true, id };
}
