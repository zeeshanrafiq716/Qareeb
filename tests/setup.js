import { beforeAll, afterAll } from "vitest";
import { setupTestDatabase } from "../src/db/setup.js";
import { closePool, query } from "../src/db/pool.js";
import { seed } from "../src/db/seed.js";
import { clearStatusCache } from "../src/db/status.js";

export async function resetDb() {
  await query(`
    TRUNCATE TABLE
      otp_codes,
      call_logs,
      provider_status_history,
      verifications,
      locations,
      providers,
      categories,
      admins
    RESTART IDENTITY CASCADE
  `);
  await query(`ALTER SEQUENCE provider_public_id_seq RESTART WITH 100001`);
  await seed();
  clearStatusCache();
}

beforeAll(async () => {
  await setupTestDatabase();
});

afterAll(async () => {
  await closePool();
});
