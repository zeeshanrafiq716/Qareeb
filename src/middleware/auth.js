import { ROLES } from "../config/constants.js";
import { query } from "../db/pool.js";
import { ForbiddenError, UnauthorizedError } from "../utils/AppError.js";
import { verifyToken } from "../utils/tokens.js";

function readToken(req) {
  const header = req.headers.authorization || "";
  if (!header.startsWith("Bearer ")) {
    throw new UnauthorizedError("Missing bearer token");
  }
  return header.slice(7).trim();
}

export async function requireProvider(req, _res, next) {
  try {
    const payload = verifyToken(readToken(req));
    if (payload.role !== ROLES.PROVIDER) {
      throw new ForbiddenError("Provider token required");
    }

    const { rows } = await query(
      `SELECT p.*, s.code AS status_code, s.label AS status_label, c.name AS category_name
       FROM providers p
       JOIN statuses s ON s.id = p.status_id
       LEFT JOIN categories c ON c.id = p.category_id
       WHERE p.id = $1`,
      [payload.sub],
    );

    if (!rows[0]) throw new UnauthorizedError("Provider not found");
    req.user = payload;
    req.provider = rows[0];
    next();
  } catch (error) {
    next(error);
  }
}

export async function requireAdmin(req, _res, next) {
  try {
    const payload = verifyToken(readToken(req));
    if (payload.role !== ROLES.ADMIN) {
      throw new ForbiddenError("Admin token required");
    }

    const { rows } = await query(
      `SELECT id, email, name, role, is_active FROM admins WHERE id = $1`,
      [payload.sub],
    );
    if (!rows[0] || !rows[0].is_active) {
      throw new UnauthorizedError("Admin account is not active");
    }

    req.user = payload;
    req.admin = rows[0];
    next();
  } catch (error) {
    next(error);
  }
}
