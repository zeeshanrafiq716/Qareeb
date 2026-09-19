import bcrypt from "bcryptjs";
import { ENTITY, PROVIDER_STATUS, VERIFICATION_STATUS } from "../config/constants.js";
import { getPool, query, withTransaction } from "../db/pool.js";
import { getStatus } from "../db/status.js";
import { AppError, NotFoundError, UnauthorizedError } from "../utils/AppError.js";
import { pagination, slugify } from "../utils/helpers.js";
import { signAdminToken } from "../utils/tokens.js";
import {
  fetchLatestVerification,
  fetchLocation,
  fetchProviderById,
  PROVIDER_SELECT,
  recordStatusChange,
  serializeAdmin,
  serializeCategory,
  serializeLocation,
  serializeProvider,
  serializeVerification,
} from "./serializers.js";

export async function adminLogin(email, password) {
  const { rows } = await query(
    `SELECT * FROM admins WHERE email = $1`,
    [String(email).toLowerCase()],
  );
  const admin = rows[0];
  if (!admin || !admin.is_active) {
    throw new UnauthorizedError("Invalid admin credentials");
  }
  const matches = await bcrypt.compare(password, admin.password_hash);
  if (!matches) throw new UnauthorizedError("Invalid admin credentials");
  return {
    token: signAdminToken(admin),
    admin: serializeAdmin(admin),
  };
}

export async function listProviders({ status, search, page, limit }) {
  const pageInfo = pagination({ page, limit });
  const values = [];
  const where = [];

  if (status) {
    values.push(status);
    where.push(`s.code = $${values.length}`);
  }
  if (search) {
    values.push(`%${search}%`);
    where.push(
      `(p.phone ILIKE $${values.length} OR p.name ILIKE $${values.length} OR p.public_id ILIKE $${values.length})`,
    );
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

  return {
    ...serializeProvider(rows[0], {
      location: serializeLocation(locationRow),
      verification: serializeVerification(verification),
    }),
    statusHistory: history.rows,
    callLogs: callLogs.rows,
  };
}

async function changeProviderStatus(providerId, admin, { fromCodes, toCode, reason, alsoVerification }) {
  return withTransaction(async (client) => {
    const provider = await fetchProviderById(client, providerId);
    if (!provider) throw new NotFoundError("Provider not found");
    if (!fromCodes.includes(provider.status_code)) {
      throw new AppError(
        409,
        `Cannot change status from ${provider.status_code} to ${toCode}`,
        "INVALID_STATUS_TRANSITION",
      );
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
    fromCodes: [PROVIDER_STATUS.PENDING_VERIFICATION],
    toCode: PROVIDER_STATUS.APPROVED,
    reason: reason || "Approved by admin",
    alsoVerification: VERIFICATION_STATUS.APPROVED,
  });
  return serializeProvider(provider);
}

export async function rejectProvider(id, admin, reason) {
  const provider = await changeProviderStatus(id, admin, {
    fromCodes: [PROVIDER_STATUS.PENDING_VERIFICATION],
    toCode: PROVIDER_STATUS.REJECTED,
    reason,
    alsoVerification: VERIFICATION_STATUS.REJECTED,
  });
  return serializeProvider(provider);
}

export async function suspendProvider(id, admin, reason) {
  const provider = await changeProviderStatus(id, admin, {
    fromCodes: [PROVIDER_STATUS.APPROVED],
    toCode: PROVIDER_STATUS.SUSPENDED,
    reason,
  });
  return serializeProvider(provider);
}

export async function reinstateProvider(id, admin, reason) {
  const provider = await changeProviderStatus(id, admin, {
    fromCodes: [PROVIDER_STATUS.SUSPENDED],
    toCode: PROVIDER_STATUS.APPROVED,
    reason: reason || "Reinstated by admin",
  });
  return serializeProvider(provider);
}

export async function listCategories() {
  const { rows } = await query(`SELECT * FROM categories ORDER BY name`);
  return rows.map(serializeCategory);
}

export async function createCategory(name) {
  const slug = slugify(name);
  try {
    const { rows } = await query(
      `INSERT INTO categories (name, slug, is_enabled) VALUES ($1, $2, true) RETURNING *`,
      [name.trim(), slug],
    );
    return serializeCategory(rows[0]);
  } catch (error) {
    if (error.code === "23505") {
      throw new AppError(409, "Category already exists", "CATEGORY_EXISTS");
    }
    throw error;
  }
}

export async function patchCategory(id, { name, isEnabled }) {
  const { rows } = await query(`SELECT * FROM categories WHERE id = $1`, [id]);
  if (!rows[0]) throw new NotFoundError("Category not found");

  const nextName = name?.trim() || rows[0].name;
  const nextSlug = name ? slugify(name) : rows[0].slug;
  const enabled = typeof isEnabled === "boolean" ? isEnabled : rows[0].is_enabled;

  try {
    const updated = await query(
      `UPDATE categories SET name = $2, slug = $3, is_enabled = $4 WHERE id = $1 RETURNING *`,
      [id, nextName, nextSlug, enabled],
    );
    return serializeCategory(updated.rows[0]);
  } catch (error) {
    if (error.code === "23505") {
      throw new AppError(409, "Category already exists", "CATEGORY_EXISTS");
    }
    throw error;
  }
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
