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
  [ENTITY.PROVIDER, PROVIDER_STATUS.BLOCKED, "Blocked", true, 70],
  [ENTITY.VERIFICATION, VERIFICATION_STATUS.PENDING, "Pending review", false, 10],
  [ENTITY.VERIFICATION, VERIFICATION_STATUS.APPROVED, "Approved", true, 20],
  [ENTITY.VERIFICATION, VERIFICATION_STATUS.REJECTED, "Rejected", true, 30],
  [ENTITY.CALL, CALL_STATUS.INITIATED, "Initiated", false, 10],
  [ENTITY.CALL, CALL_STATUS.COMPLETED, "Completed", true, 20],
  [ENTITY.CALL, CALL_STATUS.MISSED, "Missed", true, 30],
  [ENTITY.CALL, CALL_STATUS.FAILED, "Failed", true, 40],
];

export async function seed(pool = getPool(), { forceClean = false } = {}) {
  const shouldClean =
    forceClean ||
    process.argv.includes("--clean") ||
    process.argv.includes("--reset");

  // 1. Ensure all system entity statuses exist
  for (const [entityType, code, label, isTerminal, sortOrder] of DEFAULT_STATUSES) {
    await pool.query(
      `INSERT INTO statuses (entity_type, code, label, is_terminal, sort_order)
       VALUES ($1, $2, $3, $4, $5)
       ON CONFLICT (entity_type, code) DO UPDATE
       SET label = EXCLUDED.label, is_terminal = EXCLUDED.is_terminal, sort_order = EXCLUDED.sort_order`,
      [entityType, code, label, isTerminal, sortOrder],
    );
  }

  // 2. Ensure Admin account exists for Admin Panel
  const passwordHash = await bcrypt.hash(env.ADMIN_PASSWORD, env.isTest ? 4 : 10);
  await pool.query(
    `INSERT INTO admins (email, password_hash, name, role, is_active)
     VALUES ($1, $2, $3, 'admin', true)
     ON CONFLICT (email) DO UPDATE
     SET name = EXCLUDED.name, password_hash = EXCLUDED.password_hash, is_active = true`,
    [env.ADMIN_EMAIL, passwordHash, env.ADMIN_NAME],
  );

  // 3. Clean out mock records only when explicitly requested via --clean / --reset
  if (shouldClean) {
    await pool.query(`DELETE FROM call_logs`);
    await pool.query(`DELETE FROM verifications`);
    await pool.query(`DELETE FROM locations`);
    await pool.query(`DELETE FROM provider_status_history`);
    await pool.query(`DELETE FROM provider_device_tokens`);
    await pool.query(`DELETE FROM otp_codes`);
    await pool.query(`DELETE FROM otp_request_audit`);
    await pool.query(`DELETE FROM customer_funnel_events`);
    await pool.query(`DELETE FROM providers`);
    await pool.query(`ALTER SEQUENCE provider_public_id_seq RESTART WITH 100001`);
    logger.info("Database cleaned of mock records via --clean flag.");
  }

  // 4. Ensure exact 26 official categories from user's master list (bilingual & sort order support)
  await pool.query(`DELETE FROM categories WHERE slug IN ('ride', 'pickup', 'rider', 'van', 'auto', 'emergency', 'tank')`);

  const DEFAULT_CATEGORIES = [
    // [Name (English), Slug, Subtitle, SubtitleAr, NameAr (Arabic), SortOrder, IconUrl]
    ["Tow Truck", "tow-truck", "Vehicle breakdown & roadside towing", "سحب ونقل المركبات المعطلة", "سطحة", 1, "/assets/categories/tow_truck.png"],
    ["Tyre & Puncture Repair", "tyre-puncture-repair", "Mobile tyre replacement & puncture repair", "إصلاح وتبديل بنشر متنقل", "كاوتش / بنشر", 2, "/assets/categories/tyre_repair.png"],
    ["Fuel Delivery", "fuel-delivery", "Emergency petrol & diesel delivery", "توصيل بنزين وديزل للموقع", "توصيل وقود", 3, "/assets/categories/fuel_delivery.png"],
    ["Car Mechanic", "car-mechanic", "On-site mechanical diagnostics & repair", "فحص وصيانة ميكانيكا السيارات", "ميكانيكي سيارات", 4, "/assets/categories/car_mechanic.png"],
    ["Small Pickup (Dyna)", "small-pickup-dyna", "Light cargo & local transport", "نقل حمولات وبضائع خفيفة", "دينا صغيرة", 5, "/assets/categories/small_pickup_dyna.png"],
    ["Large Pickup (Dyna)", "large-pickup-dyna", "Commercial transport & large moves", "نقل عفش وبضائع تجارية كبيرة", "دينا كبيرة", 6, "/assets/categories/large_pickup_dyna.png"],
    ["Small Water Tanker", "small-water-tanker", "Clean potable water delivery", "توصيل وايت ماء صالح للشرب", "صهريج ماء صغير", 7, "/assets/categories/small_water_tanker.png"],
    ["Large Water Tanker", "large-water-tanker", "Bulk water supply & storage refill", "تعبئة وتوريد صهاريج مياه كبيرة", "صهريج ماء كبير", 8, "/assets/categories/large_water_tanker.png"],
    ["Battery Jump Start", "battery-jump-start", "Quick battery boost & mobile replacement", "اشتراك بطارية وتبديل فوري", "بطارية – جامب ستارتر", 9, "/assets/categories/battery_jump_start.png"],
    ["AC Technician", "ac-technician", "AC repair, gas recharge & duct cleaning", "صيانة وتبريد وتعبئة فريون المكيفات", "فني مكيف هواء", 10, "/assets/categories/ac_technician.png"],
    ["Electrician", "electrician", "Residential electrical wiring & repairs", "صيانة وتمديدات كهربائية منزلية", "كهربائي", 11, "/assets/categories/electrician.png"],
    ["Plumber", "plumber", "Plumbing leaks, piping & fixtures", "سباكة وإصلاح تسريبات المياه", "سباك", 12, "/assets/categories/plumber.png"],
    ["House Cleaning", "house-cleaning", "Deep residential & commercial cleaning", "تنظيف فلل وشقق وتعقيم شامل", "تنظيف منازل", 13, "/assets/categories/house_cleaning.png"],
    ["Washing Machine Tech", "washing-machine-tech", "Washing machine & dryer diagnostics", "صيانة وتصليح الغسالات والنشافات", "فني غسالات", 14, "/assets/categories/washing_machine_tech.png"],
    ["Refrigerator Tech", "refrigerator-tech", "Refrigerator cooling & compressor repair", "صيانة وتبريد الثلاجات والفريزر", "فني ثلاجة", 15, "/assets/categories/refrigerator_tech.png"],
    ["Appliance Technician", "appliance-technician", "Stoves, ovens & small appliance repair", "إصلاح الأفران والأجهزة الكهربائية", "صيانة أجهزة", 16, "/assets/categories/appliance_technician.png"],
    ["Tiles & Ceramic", "tiles-ceramic", "Tile installation, renovation & grouting", "تركيب وتجديد البلاط والسيراميك", "فني بلاط وسيراميك", 17, "/assets/categories/tiles_ceramic.png"],
    ["Carpenter", "carpenter", "Custom wood furniture & door repair", "أعمال نجارة وصيانة الأبواب والأثاث", "نجار", 18, "/assets/categories/carpenter.png"],
    ["Painter", "painter", "Interior & exterior wall painting", "دهانات وديكورات داخلية وخارجية", "دهان", 19, "/assets/categories/painter.png"],
    ["Pest Control", "pest-control", "Safe pest elimination & spraying", "رش مبيدات ومكافحة الحشرات والقوارض", "مكافحة حشرات", 20, "/assets/categories/pest_control.png"],
    ["Network Technician", "network-technician", "Wi-Fi routers, Ethernet & network setup", "تمديد وبرمجة الشبكات والإنترنت", "فني شبكات", 21, "/assets/categories/network_technician.png"],
    ["CCTV Technician", "cctv-technician", "Security camera installation & DVR setup", "تركيب وبرمجة كاميرات المراقبة", "فني كاميرات مراقبة", 22, "/assets/categories/cctv_technician.png"],
    ["Curtain Installation", "curtain-installation", "Drapery tracks & curtain installation", "تفصيل وتركيب الستائر والمسارات", "تركيب ستائر", 23, "/assets/categories/curtain_installation.png"],
    ["Doors & Locks", "doors-locks", "Smart locks, handles & key cylinder fitting", "فتح وتركيب الأقفال والأبواب الذكية", "فني أبواب وأقفال", 24, "/assets/categories/doors_locks.png"],
    ["Construction & Renovation", "construction-renovation", "General building renovation & masonry", "مقاولات وترميم وتشطيب مباني", "أعمال بناء وترميم", 25, "/assets/categories/construction_renovation.png"],
    ["Pool Maintenance", "pool-maintenance", "Swimming pool cleaning, filters & pumps", "تنظيف وتعقيم وصيانة فلاتر المسابح", "صيانة مسابح", 26, "/assets/categories/pool_maintenance.png"],
  ];

  for (const [name, slug, subtitle, subtitleAr, nameAr, sortOrder, iconUrl] of DEFAULT_CATEGORIES) {
    await pool.query(
      `INSERT INTO categories (name, slug, subtitle, subtitle_ar, name_ar, sort_order, icon_url, is_enabled)
       VALUES ($1, $2, $3, $4, $5, $6, $7, true)
       ON CONFLICT (slug) DO UPDATE SET 
         is_enabled = true, 
         name = EXCLUDED.name, 
         name_ar = EXCLUDED.name_ar, 
         subtitle = EXCLUDED.subtitle, 
         subtitle_ar = EXCLUDED.subtitle_ar, 
         sort_order = EXCLUDED.sort_order,
         icon_url = EXCLUDED.icon_url`,
      [name, slug, subtitle, subtitleAr, nameAr, sortOrder, iconUrl],
    );
  }

  const DEFAULT_VEHICLE_TYPES = [
    ["Flatbed Tow Truck", "flatbed-tow-truck", 1, "سطحة عادية"],
    ["Hydraulic Low Flatbed", "hydraulic-low-flatbed", 2, "سطحة هيدروليك"],
    ["Wheel Lift Tow Truck", "wheel-lift-tow-truck", 3, "ونش رفع"],
    ["Heavy Duty Recovery Truck", "heavy-duty-recovery-truck", 4, "سطحة ثقيل"],
    ["Covered Carrier", "covered-carrier-vip", 5, "سطحة مغلقة VIP"],
    ["Motorbike Carrier", "motorbike-carrier", 6, "سطحة دبابات"],
  ];

  for (const [name, slug, sortOrder, nameAr] of DEFAULT_VEHICLE_TYPES) {
    await pool.query(
      `INSERT INTO vehicle_types (name, slug, sort_order, name_ar, is_enabled)
       VALUES ($1, $2, $3, $4, true)
       ON CONFLICT (slug) DO UPDATE SET is_enabled = true, name = EXCLUDED.name, name_ar = EXCLUDED.name_ar, sort_order = EXCLUDED.sort_order`,
      [name, slug, sortOrder, nameAr],
    );
  }

  if (shouldClean) {
    await pool.query(`ALTER SEQUENCE provider_public_id_seq RESTART WITH 100001`);
  }

  clearStatusCache();
  logger.info("Database schema & dictionary data ready.");
}

if (process.argv[1]?.endsWith("seed.js")) {
  seed()
    .then(() => process.exit(0))
    .catch((error) => {
      logger.error({ err: error }, "Seed failed");
      process.exit(1);
    });
}
