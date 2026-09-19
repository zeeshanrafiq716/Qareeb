import bcrypt from "bcryptjs";
import { env } from "../config/env.js";
import {
  CALL_STATUS,
  ENTITY,
  PROVIDER_STATUS,
  VERIFICATION_STATUS,
} from "../config/constants.js";
import { logger } from "../logger.js";
import { slugify } from "../utils/helpers.js";
import { getPool } from "./pool.js";
import { clearStatusCache } from "./status.js";

const DEFAULT_STATUSES = [
  [ENTITY.PROVIDER, PROVIDER_STATUS.PENDING_OTP, "Pending OTP", false, 10],
  [ENTITY.PROVIDER, PROVIDER_STATUS.PENDING_PROFILE, "Pending profile", false, 20],
  [ENTITY.PROVIDER, PROVIDER_STATUS.PENDING_VERIFICATION, "Pending verification", false, 30],
  [ENTITY.PROVIDER, PROVIDER_STATUS.APPROVED, "Approved", false, 40],
  [ENTITY.PROVIDER, PROVIDER_STATUS.REJECTED, "Rejected", true, 50],
  [ENTITY.PROVIDER, PROVIDER_STATUS.SUSPENDED, "Suspended", false, 60],
  [ENTITY.VERIFICATION, VERIFICATION_STATUS.PENDING, "Pending review", false, 10],
  [ENTITY.VERIFICATION, VERIFICATION_STATUS.APPROVED, "Approved", true, 20],
  [ENTITY.VERIFICATION, VERIFICATION_STATUS.REJECTED, "Rejected", true, 30],
  [ENTITY.CALL, CALL_STATUS.INITIATED, "Initiated", false, 10],
  [ENTITY.CALL, CALL_STATUS.COMPLETED, "Completed", true, 20],
  [ENTITY.CALL, CALL_STATUS.MISSED, "Missed", true, 30],
  [ENTITY.CALL, CALL_STATUS.FAILED, "Failed", true, 40],
];

const DEFAULT_CATEGORIES = [
  "Plumber",
  "Electrician",
  "Carpenter",
  "AC Technician",
  "Painter",
  "Mechanic",
  "Cleaner",
  "Pest Control",
];

export async function seed(pool = getPool()) {
  for (const [entityType, code, label, isTerminal, sortOrder] of DEFAULT_STATUSES) {
    await pool.query(
      `INSERT INTO statuses (entity_type, code, label, is_terminal, sort_order)
       VALUES ($1, $2, $3, $4, $5)
       ON CONFLICT (entity_type, code) DO UPDATE
       SET label = EXCLUDED.label, is_terminal = EXCLUDED.is_terminal, sort_order = EXCLUDED.sort_order`,
      [entityType, code, label, isTerminal, sortOrder],
    );
  }

  for (const name of DEFAULT_CATEGORIES) {
    await pool.query(
      `INSERT INTO categories (name, slug, is_enabled)
       VALUES ($1, $2, true)
       ON CONFLICT (slug) DO NOTHING`,
      [name, slugify(name)],
    );
  }

  const passwordHash = await bcrypt.hash(env.ADMIN_PASSWORD, env.isTest ? 4 : 10);
  await pool.query(
    `INSERT INTO admins (email, password_hash, name, role, is_active)
     VALUES ($1, $2, $3, 'admin', true)
     ON CONFLICT (email) DO UPDATE
     SET name = EXCLUDED.name, password_hash = EXCLUDED.password_hash, is_active = true`,
    [env.ADMIN_EMAIL, passwordHash, env.ADMIN_NAME],
  );

  clearStatusCache();
  logger.info("Seed data ready");
}

if (process.argv[1]?.endsWith("seed.js")) {
  seed()
    .then(() => process.exit(0))
    .catch((error) => {
      logger.error({ err: error }, "Seed failed");
      process.exit(1);
    });
}
