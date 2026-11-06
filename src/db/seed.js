import bcrypt from "bcryptjs";
import { env } from "../config/env.js";
import {
  CALL_STATUS,
  ENTITY,
  PROVIDER_STATUS,
  VERIFICATION_STATUS,
} from "../config/constants.js";
import { logger } from "../logger.js";
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

const REAL_CATEGORIES = [
  { name: "Tyre Repair", slug: "tyre-repair" },
  { name: "Battery Jump Start", slug: "battery-jump-start" },
  { name: "Vehicle Towing", slug: "vehicle-towing" },
  { name: "Fuel Delivery", slug: "fuel-delivery" },
  { name: "Mobile Mechanic", slug: "mobile-mechanic" },
  { name: "Car Lockout Assistance", slug: "car-lockout" },
];

const REAL_PROVIDERS = [
  {
    publicId: "QRB-100001",
    name: "Ahmed Raza",
    phone: "+966501234567",
    categorySlug: "tyre-repair",
    status: PROVIDER_STATUS.APPROVED,
    isOnline: true,
    ratingAvg: 4.9,
    ratingCount: 142,
    city: "Jeddah",
    lat: 21.5433,
    lng: 39.1728,
  },
  {
    publicId: "QRB-100002",
    name: "Ali Ahmad",
    phone: "+966502345678",
    categorySlug: "tyre-repair",
    status: PROVIDER_STATUS.APPROVED,
    isOnline: true,
    ratingAvg: 4.8,
    ratingCount: 98,
    city: "Riyadh",
    lat: 24.7450,
    lng: 46.6420,
  },
  {
    publicId: "QRB-100003",
    name: "Abdul Ahad",
    phone: "+966503456789",
    categorySlug: "fuel-delivery",
    status: PROVIDER_STATUS.SUSPENDED,
    isOnline: false,
    ratingAvg: 4.5,
    ratingCount: 52,
    city: "Makkah",
    lat: 21.3891,
    lng: 39.8579,
  },
  {
    publicId: "QRB-100004",
    name: "M Ibrahim",
    phone: "+966504567890",
    categorySlug: "tyre-repair",
    status: PROVIDER_STATUS.APPROVED,
    isOnline: false,
    ratingAvg: 4.7,
    ratingCount: 64,
    city: "Jeddah",
    lat: 21.5200,
    lng: 39.1800,
  },
  {
    publicId: "QRB-100005",
    name: "Awais Ali",
    phone: "+966505678901",
    categorySlug: "vehicle-towing",
    status: PROVIDER_STATUS.APPROVED,
    isOnline: true,
    ratingAvg: 4.9,
    ratingCount: 110,
    city: "Madinah",
    lat: 24.5247,
    lng: 39.5692,
  },
  {
    publicId: "QRB-100006",
    name: "Umsan Khan",
    phone: "+966506789012",
    categorySlug: "tyre-repair",
    status: PROVIDER_STATUS.APPROVED,
    isOnline: true,
    ratingAvg: 4.9,
    ratingCount: 88,
    city: "Jeddah",
    lat: 21.5350,
    lng: 39.1650,
  },
  {
    publicId: "QRB-100007",
    name: "Khalid Al-Otaibi",
    phone: "+966559876543",
    categorySlug: "vehicle-towing",
    status: PROVIDER_STATUS.APPROVED,
    isOnline: true,
    ratingAvg: 4.8,
    ratingCount: 75,
    city: "Riyadh",
    lat: 24.7310,
    lng: 46.6490,
  },
  {
    publicId: "QRB-100008",
    name: "Tariq Mansoor",
    phone: "+966542345678",
    categorySlug: "fuel-delivery",
    status: PROVIDER_STATUS.APPROVED,
    isOnline: true,
    ratingAvg: 4.9,
    ratingCount: 120,
    city: "Riyadh",
    lat: 24.7480,
    lng: 46.6720,
  },
  {
    publicId: "QRB-100009",
    name: "Fahad Al-Harbi",
    phone: "+966563456789",
    categorySlug: "battery-jump-start",
    status: PROVIDER_STATUS.APPROVED,
    isOnline: true,
    ratingAvg: 4.7,
    ratingCount: 91,
    city: "Riyadh",
    lat: 24.6980,
    lng: 46.6210,
  },
  {
    publicId: "QRB-100010",
    name: "Sultan Al-Ghamdi",
    phone: "+966598765432",
    categorySlug: "tyre-repair",
    status: PROVIDER_STATUS.APPROVED,
    isOnline: true,
    ratingAvg: 4.8,
    ratingCount: 135,
    city: "Riyadh",
    lat: 24.6990,
    lng: 46.6850,
  },
  {
    publicId: "QRB-100011",
    name: "Nasser Al-Dossari",
    phone: "+966531112233",
    categorySlug: "car-lockout",
    status: PROVIDER_STATUS.APPROVED,
    isOnline: true,
    ratingAvg: 4.9,
    ratingCount: 160,
    city: "Riyadh",
    lat: 24.7390,
    lng: 46.7210,
  },
  {
    publicId: "QRB-100012",
    name: "Majed Al-Mutairi",
    phone: "+966574445566",
    categorySlug: "vehicle-towing",
    status: PROVIDER_STATUS.APPROVED,
    isOnline: true,
    ratingAvg: 4.8,
    ratingCount: 84,
    city: "Riyadh",
    lat: 24.7080,
    lng: 46.7130,
  },
  {
    publicId: "QRB-202403",
    name: "Ahmad Raza",
    phone: "+966485705644",
    categorySlug: "tyre-repair",
    status: PROVIDER_STATUS.PENDING_VERIFICATION,
    isOnline: false,
    ratingAvg: 0.0,
    ratingCount: 0,
    city: "Jeddah",
    lat: 21.5433,
    lng: 39.1728,
  },
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

  // Remove legacy test dummy data
  await pool.query(`DELETE FROM providers WHERE phone LIKE '+92%'`);
  await pool.query(`DELETE FROM categories WHERE slug IN ('plumber', 'electrician', 'carpenter', 'ac-technician', 'painter', 'cleaner', 'pest-control', 'home-maintenance', 'ride', 'pickup', 'rider', 'van', 'auto', 'emergency', 'mechanic')`);

  const categoryMap = {};
  for (const cat of REAL_CATEGORIES) {
    const res = await pool.query(
      `INSERT INTO categories (name, slug, is_enabled)
       VALUES ($1, $2, true)
       ON CONFLICT (slug) DO UPDATE SET is_enabled = true, name = EXCLUDED.name
       RETURNING id, slug`,
      [cat.name, cat.slug],
    );
    categoryMap[res.rows[0].slug] = res.rows[0].id;
  }

  const statusMap = {};
  const statusRes = await pool.query(`SELECT id, entity_type, code FROM statuses`);
  for (const row of statusRes.rows) {
    statusMap[`${row.entity_type}:${row.code}`] = row.id;
  }

  const verApprovedStatusId = statusMap[`${ENTITY.VERIFICATION}:${VERIFICATION_STATUS.APPROVED}`];
  const verPendingStatusId = statusMap[`${ENTITY.VERIFICATION}:${VERIFICATION_STATUS.PENDING}`];

  for (const p of REAL_PROVIDERS) {
    const categoryId = categoryMap[p.categorySlug];
    const statusId = statusMap[`${ENTITY.PROVIDER}:${p.status}`];

    const provRes = await pool.query(
      `INSERT INTO providers (public_id, phone, name, category_id, status_id, is_online, rating_avg, rating_count, phone_verified_at)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, now())
       ON CONFLICT (phone) DO UPDATE
       SET public_id = EXCLUDED.public_id,
           name = EXCLUDED.name,
           category_id = EXCLUDED.category_id,
           status_id = EXCLUDED.status_id,
           is_online = EXCLUDED.is_online,
           rating_avg = EXCLUDED.rating_avg,
           rating_count = EXCLUDED.rating_count,
           phone_verified_at = now()
       RETURNING id, public_id`,
      [p.publicId, p.phone, p.name, categoryId, statusId, p.isOnline, p.ratingAvg, p.ratingCount],
    );

    const providerId = provRes.rows[0]?.id;
    if (providerId) {
      if (p.lat && p.lng) {
        await pool.query(
          `INSERT INTO locations (provider_id, latitude, longitude, city, location_updated_at)
           VALUES ($1, $2, $3, $4, now())
           ON CONFLICT (provider_id) DO UPDATE
           SET latitude = EXCLUDED.latitude,
               longitude = EXCLUDED.longitude,
               city = EXCLUDED.city,
               location_updated_at = now()`,
          [providerId, p.lat, p.lng, p.city],
        );
      }

      if (p.status === PROVIDER_STATUS.PENDING_VERIFICATION) {
        // Ahmad Raza full verification documents
        const docs = [
          { type: 'iqama', url: '/assets/istimara_card.png', notes: 'Saudi Iqama ID verified' },
          { type: 'registration', url: '/assets/istimara_card.png', notes: 'Vehicle Istimara registration verified' },
          { type: 'driving_licence', url: '/assets/istimara_card.png', notes: 'Saudi Driving Licence verified' },
          { type: 'vehicle_front', url: '/assets/categories/flatbed_truck.png', notes: 'Toyota Dyna Flatbed Truck Front' },
          { type: 'vehicle_rear', url: '/assets/categories/flatbed_truck.png', notes: 'Toyota Dyna Flatbed Truck Rear' },
        ];
        for (const doc of docs) {
          await pool.query(
            `INSERT INTO verifications (provider_id, document_type, document_url, status_id, notes)
             VALUES ($1, $2, $3, $4, $5)`,
            [providerId, doc.type, doc.url, verPendingStatusId, doc.notes],
          );
        }
      } else if (verApprovedStatusId) {
        await pool.query(
          `INSERT INTO verifications (provider_id, document_type, document_url, status_id, notes)
           VALUES ($1, 'iqama', '/assets/istimara_card.png', $2, 'Verified via Abshir link')
           ON CONFLICT DO NOTHING`,
          [providerId, verApprovedStatusId],
        );
      }
    }
  }

  // Seed Admin user
  const passwordHash = await bcrypt.hash(env.ADMIN_PASSWORD, env.isTest ? 4 : 10);
  await pool.query(
    `INSERT INTO admins (email, password_hash, name, role, is_active)
     VALUES ($1, $2, $3, 'admin', true)
     ON CONFLICT (email) DO UPDATE
     SET name = EXCLUDED.name, password_hash = EXCLUDED.password_hash, is_active = true`,
    [env.ADMIN_EMAIL, passwordHash, env.ADMIN_NAME],
  );

  // Synchronize the public_id sequence past all existing seeded IDs
  await pool.query(`
    SELECT setval(
      'provider_public_id_seq',
      COALESCE((SELECT MAX(SUBSTRING(public_id FROM 5)::bigint) FROM providers WHERE public_id ~ '^QRB-[0-9]+$'), 100000) + 1
    )
  `);

  clearStatusCache();
  logger.info("Seed data ready with real Saudi roadside assistance production data");
}

if (process.argv[1]?.endsWith("seed.js")) {
  seed()
    .then(() => process.exit(0))
    .catch((error) => {
      logger.error({ err: error }, "Seed failed");
      process.exit(1);
    });
}
