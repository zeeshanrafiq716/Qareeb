import { beforeEach, describe, expect, it } from "vitest";
import { query } from "../src/db/pool.js";
import { resetDb } from "./setup.js";
import { completeRegistration } from "./helpers.js";

describe("database relationships, constraints and indexes", () => {
  beforeEach(async () => {
    await resetDb();
  });

  it("enforces unique phone numbers", async () => {
    await completeRegistration("03050000001");
    await expect(
      query(
        `INSERT INTO providers (public_id, phone, status_id)
         SELECT 'QRB-999999', '+923050000001', id FROM statuses WHERE entity_type = 'provider' AND code = 'pending_otp'`,
      ),
    ).rejects.toMatchObject({ code: "23505" });
  });

  it("enforces unique provider public IDs", async () => {
    await completeRegistration("03050000002");
    await expect(
      query(
        `INSERT INTO providers (public_id, phone, status_id)
         SELECT 'QRB-100001', '+923050000099', id FROM statuses WHERE entity_type = 'provider' AND code = 'pending_otp'`,
      ),
    ).rejects.toMatchObject({ code: "23505" });
  });

  it("keeps one location per provider", async () => {
    const created = await completeRegistration("03050000003");
    await expect(
      query(
        `INSERT INTO locations (provider_id, city) VALUES ($1, 'Karachi')`,
        [created.provider.id],
      ),
    ).rejects.toMatchObject({ code: "23505" });
  });

  it("rejects out-of-range coordinates", async () => {
    const created = await completeRegistration("03050000004");
    await expect(
      query(`UPDATE locations SET latitude = 123 WHERE provider_id = $1`, [created.provider.id]),
    ).rejects.toMatchObject({ code: "23514" });
  });

  it("cascades location, verification, history and call logs when a provider is deleted", async () => {
    const created = await completeRegistration("03050000005");
    const id = created.provider.id;
    await query(
      `INSERT INTO call_logs (provider_id, caller_phone, status_id)
       SELECT $1, '+923001110000', id FROM statuses WHERE entity_type = 'call' AND code = 'initiated'`,
      [id],
    );

    await query(`DELETE FROM providers WHERE id = $1`, [id]);

    const leftover = await query(
      `SELECT
         (SELECT COUNT(*) FROM locations WHERE provider_id = $1) AS locations,
         (SELECT COUNT(*) FROM verifications WHERE provider_id = $1) AS verifications,
         (SELECT COUNT(*) FROM provider_status_history WHERE provider_id = $1) AS history,
         (SELECT COUNT(*) FROM call_logs WHERE provider_id = $1) AS calls`,
      [id],
    );
    expect(leftover.rows[0]).toEqual({
      locations: "0",
      verifications: "0",
      history: "0",
      calls: "0",
    });
  });

  it("has the required Phase 1 tables and indexes", async () => {
    const tables = await query(
      `SELECT table_name FROM information_schema.tables
       WHERE table_schema = 'public' AND table_type = 'BASE TABLE'`,
    );
    const names = tables.rows.map((row) => row.table_name);
    for (const table of [
      "providers",
      "categories",
      "verifications",
      "statuses",
      "locations",
      "call_logs",
      "admins",
    ]) {
      expect(names).toContain(table);
    }

    const indexes = await query(
      `SELECT indexname FROM pg_indexes WHERE schemaname = 'public'`,
    );
    const indexNames = indexes.rows.map((row) => row.indexname);
    expect(indexNames).toEqual(expect.arrayContaining([
      "providers_phone_unique",
      "providers_public_id_unique",
      "idx_providers_status_id",
      "idx_verifications_provider_id",
      "locations_provider_unique",
    ]));
  });
});
