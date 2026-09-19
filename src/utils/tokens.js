import jwt from "jsonwebtoken";
import { env } from "../config/env.js";
import { ROLES } from "../config/constants.js";
import { UnauthorizedError } from "./AppError.js";

export function signProviderToken(provider) {
  return jwt.sign(
    {
      sub: provider.id,
      role: ROLES.PROVIDER,
      publicId: provider.public_id,
    },
    env.JWT_SECRET,
    { expiresIn: env.JWT_PROVIDER_EXPIRES_IN },
  );
}

export function signAdminToken(admin) {
  return jwt.sign(
    {
      sub: admin.id,
      role: ROLES.ADMIN,
      email: admin.email,
    },
    env.JWT_SECRET,
    { expiresIn: env.JWT_ADMIN_EXPIRES_IN },
  );
}

export function verifyToken(token) {
  try {
    return jwt.verify(token, env.JWT_SECRET);
  } catch {
    throw new UnauthorizedError("Invalid or expired token");
  }
}
