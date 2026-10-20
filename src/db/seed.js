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
  { name: "Ride", slug: "ride" },
  { name: "Pickup", slug: "pickup" },
  { name: "Rider", slug: "rider" },
  { name: "Van", slug: "van" },
  { name: "Home Care", slug: "home-maintenance" },
  { name: "Emergency", slug: "emergency" },
  { name: "Plumber", slug: "plumber" },
  { name: "Electrician", slug: "electrician" },
  { name: "Carpenter", slug: "carpenter" },
  { name: "AC Technician", slug: "ac-technician" },
  { name: "Painter", slug: "painter" },
  { name: "Mechanic", slug: "mechanic" },
  { name: "Cleaner", slug: "cleaner" },
  { name: "Pest Control", slug: "pest-control" },
];

const DEFAULT_PROVIDERS = [
  { name: "Uzair Ahmed", phone: "+923001234501", ratingAvg: 4.9, ratingCount: 142, categorySlug: "pickup" },
  { name: "Adnan Said", phone: "+923001234502", ratingAvg: 4.8, ratingCount: 98, categorySlug: "pickup" },
  { name: "Abdul Rehman", phone: "+923001234503", ratingAvg: 5.0, ratingCount: 215, categorySlug: "ride" },
  { name: "Mehmood Khan", phone: "+923001234504", ratingAvg: 4.9, ratingCount: 88, categorySlug: "pickup" },
  { name: "Ubaid Ullah", phone: "+923001234505", ratingAvg: 4.9, ratingCount: 160, categorySlug: "rider" },
  { name: "Rayan Tariq", phone: "+923001234506", ratingAvg: 4.8, ratingCount: 75, categorySlug: "pickup" },
  { name: "Omar Farooq", phone: "+923001234507", ratingAvg: 4.9, ratingCount: 130, categorySlug: "ride" },
  { name: "Saad Ali", phone: "+923001234508", ratingAvg: 4.9, ratingCount: 112, categorySlug: "van" },
  { name: "Hassan Raza", phone: "+923001234509", ratingAvg: 4.7, ratingCount: 64, categorySlug: "pickup" },
  { name: "Ahmad Bilal", phone: "+923001234510", ratingAvg: 5.0, ratingCount: 310, categorySlug: "ride" },
  { name: "Tariq Mehmood", phone: "+923001234511", ratingAvg: 4.8, ratingCount: 92, categorySlug: "pickup" },
  { name: "Hamza Sheikh", phone: "+923001234512", ratingAvg: 4.9, ratingCount: 104, categorySlug: "ride" },
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

  for (const cat of DEFAULT_CATEGORIES) {
    await pool.query(
      `INSERT INTO categories (name, slug, is_enabled)
       VALUES ($1, $2, true)
       ON CONFLICT (slug) DO UPDATE SET is_enabled = true, name = EXCLUDED.name`,
      [cat.name, cat.slug],
    );
  }

  // Get approved provider status id
  const provApprovedStatus = await pool.query(
    `SELECT id FROM statuses WHERE entity_type = $1 AND code = $2`,
    [ENTITY.PROVIDER, PROVIDER_STATUS.APPROVED],
  );
  const providerStatusId = provApprovedStatus.rows[0]?.id;

  const verApprovedStatus = await pool.query(
    `SELECT id FROM statuses WHERE entity_type = $1 AND code = $2`,
    [ENTITY.VERIFICATION, VERIFICATION_STATUS.APPROVED],
  );
  const verStatusId = verApprovedStatus.rows[0]?.id;

  // Seed default approved providers
  for (const p of DEFAULT_PROVIDERS) {
    const catRes = await pool.query(`SELECT id FROM categories WHERE slug = $1`, [p.categorySlug]);
    const categoryId = catRes.rows[0]?.id;

    const provRes = await pool.query(
      `INSERT INTO providers (public_id, phone, name, category_id, status_id, is_online, rating_avg, rating_count, phone_verified_at)
       VALUES ('QRB-' || nextval('provider_public_id_seq'), $1, $2, $3, $4, true, $5, $6, now())
       ON CONFLICT (phone) DO UPDATE
       SET name = EXCLUDED.name,
           category_id = EXCLUDED.category_id,
           status_id = EXCLUDED.status_id,
           is_online = true,
           rating_avg = EXCLUDED.rating_avg,
           rating_count = EXCLUDED.rating_count,
           phone_verified_at = now()
       RETURNING id`,
      [p.phone, p.name, categoryId, providerStatusId, p.ratingAvg, p.ratingCount],
    );

    const providerId = provRes.rows[0]?.id;
    if (providerId && verStatusId) {
      await pool.query(
        `INSERT INTO verifications (provider_id, document_type, document_url, status_id)
         VALUES ($1, 'cnic', 'https://storage.qareeb.app/docs/verified_badge.png', $2)
         ON CONFLICT DO NOTHING`,
        [providerId, verStatusId],
      );
    }
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
