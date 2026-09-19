export function serializeProvider(row, extras = {}) {
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
    location: extras.location ?? null,
    verification: extras.verification ?? extras.latestVerification ?? null,
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
    slug: row.slug,
    isEnabled: row.is_enabled,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  };
}

const PROVIDER_SELECT = `
  SELECT p.*,
         s.code AS status_code,
         s.label AS status_label,
         c.name AS category_name,
         c.is_enabled AS category_enabled
  FROM providers p
  JOIN statuses s ON s.id = p.status_id
  LEFT JOIN categories c ON c.id = p.category_id
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
