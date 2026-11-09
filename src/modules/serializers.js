export function serializeProvider(row, extras = {}) {
  const loc =
    extras.location ??
    (row.city != null || row.latitude != null
      ? {
          city: row.city,
          latitude: row.latitude === null ? null : Number(row.latitude),
          longitude: row.longitude === null ? null : Number(row.longitude),
          address: row.address,
          updatedAt: row.location_updated_at ?? null,
        }
      : null);

  const isOnline = Boolean(extras.isOnline ?? row.is_online);
  const lastSeenAt = row.last_seen_at ?? null;

  return {
    id: row.id,
    providerId: row.public_id,
    phone: row.phone,
    phoneVerifiedAt: row.phone_verified_at,
    name: row.name,
    photoUrl: row.photo_url,
    status: row.status_code,
    statusLabel: row.status_label,
    statusReason: row.status_reason,
    category: row.category_id
      ? {
          id: row.category_id,
          name: row.category_name,
          enabled: row.category_enabled ?? true,
        }
      : null,
    whatsapp: row.whatsapp_number || row.phone,
    whatsappNumber: row.whatsapp_number || null,
    nationalId: row.iqama_number || null,
    iqamaNumber: row.iqama_number || null,
    iqamaExpiry: row.iqama_expiry || null,
    vehicleType: row.vehicle_type_name || row.vehicle_type_db_name || null,
    vehicleTypeId: row.vehicle_type_id || null,
    vehicleModel: row.vehicle_model || null,
    plateNumber: row.plate_number || null,
    vehicleColor: row.vehicle_color || null,
    location: loc,
    isOnline,
    lastSeenAt,
    presence: extras.presence ?? {
      isOnline,
      lastSeenAt,
      locationUpdatedAt: row.location_updated_at ?? null,
    },
    verification: extras.verification ?? extras.latestVerification ?? null,
    documents: extras.documents ?? null,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  };
}

export function serializeVerification(row) {
  if (!row) return null;
  return {
    id: row.id,
    documentType: row.document_type,
    documentUrl: row.document_url,
    status: row.status_code,
    notes: row.notes,
    reviewedAt: row.reviewed_at,
    createdAt: row.created_at,
  };
}

export function serializeLocation(row) {
  if (!row) return null;
  return {
    latitude: row.latitude === null ? null : Number(row.latitude),
    longitude: row.longitude === null ? null : Number(row.longitude),
    address: row.address,
    city: row.city,
  };
}

export function serializeAdmin(row) {
  return {
    id: row.id,
    email: row.email,
    name: row.name,
    role: row.role,
  };
}

export function serializeCategory(row) {
  return {
    id: row.id,
    name: row.name,
    nameAr: row.name_ar || null,
    name_ar: row.name_ar || null,
    slug: row.slug,
    isEnabled: row.is_enabled,
    sortOrder: row.sort_order ?? 0,
    sort_order: row.sort_order ?? 0,
    subtitle: row.subtitle || null,
    subtitleAr: row.subtitle_ar || null,
    subtitle_ar: row.subtitle_ar || null,
    iconUrl: row.icon_url || null,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  };
}

export function serializeVehicleType(row) {
  return {
    id: row.id,
    name: row.name,
    nameAr: row.name_ar || null,
    name_ar: row.name_ar || null,
    slug: row.slug,
    categoryId: row.category_id || null,
    categoryName: row.category_name || null,
    icon: row.icon || null,
    isEnabled: row.is_enabled ?? true,
    sortOrder: row.sort_order ?? 0,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  };
}

const PROVIDER_SELECT = `
  SELECT p.*,
         s.code AS status_code,
         s.label AS status_label,
         c.name AS category_name,
         c.is_enabled AS category_enabled,
         loc.city AS city,
         loc.latitude AS latitude,
         loc.longitude AS longitude,
         loc.address AS address,
         loc.location_updated_at AS location_updated_at,
         vt.name AS vehicle_type_db_name,
         vt.name_ar AS vehicle_type_db_name_ar
  FROM providers p
  JOIN statuses s ON s.id = p.status_id
  LEFT JOIN categories c ON c.id = p.category_id
  LEFT JOIN locations loc ON loc.provider_id = p.id
  LEFT JOIN vehicle_types vt ON vt.id = p.vehicle_type_id
`;

export async function fetchProviderById(client, id) {
  const { rows } = await client.query(`${PROVIDER_SELECT} WHERE p.id = $1`, [id]);
  return rows[0] || null;
}

export async function fetchProviderByPhone(client, phone) {
  const { rows } = await client.query(`${PROVIDER_SELECT} WHERE p.phone = $1`, [phone]);
  return rows[0] || null;
}

export async function fetchLatestVerification(client, providerId) {
  const { rows } = await client.query(
    `SELECT v.*, s.code AS status_code
     FROM verifications v
     JOIN statuses s ON s.id = v.status_id
     WHERE v.provider_id = $1
     ORDER BY v.created_at DESC
     LIMIT 1`,
    [providerId],
  );
  return rows[0] || null;
}

export async function fetchLocation(client, providerId) {
  const { rows } = await client.query(`SELECT * FROM locations WHERE provider_id = $1`, [providerId]);
  return rows[0] || null;
}

export async function recordStatusChange(client, { providerId, fromStatusId, toStatusId, adminId, reason }) {
  await client.query(
    `INSERT INTO provider_status_history
      (provider_id, from_status_id, to_status_id, changed_by_admin_id, reason)
     VALUES ($1, $2, $3, $4, $5)`,
    [providerId, fromStatusId || null, toStatusId, adminId || null, reason || null],
  );
}

export { PROVIDER_SELECT };
