import { beforeEach, describe, expect, it } from "vitest";
import { query } from "../src/db/pool.js";
import { PROVIDER_STATUS } from "../src/config/constants.js";
import {
  buildPresence,
  setOnline,
  setOffline,
  sweepStaleProviders,
  touchLastSeen,
} from "../src/modules/presence.service.js";
import { resetConnectionsForTests } from "../src/realtime/connections.js";
import { completeRegistration, adminAuth, api } from "./helpers.js";
import { resetDb } from "./setup.js";

describe("Phase 2 presence", () => {
  beforeEach(async () => {
    resetConnectionsForTests();
    await resetDb();
  });

  it("marks provider online and offline in database", async () => {
    const { provider } = await completeRegistration("03070000001");
    await query(
      `UPDATE providers SET status_id = (SELECT id FROM statuses WHERE code = $2 LIMIT 1)
       WHERE id = $1`,
      [provider.id, PROVIDER_STATUS.APPROVED],
    );

    await setOnline(provider.id);
    let row = (await query(`SELECT is_online, last_seen_at FROM providers WHERE id = $1`, [provider.id]))
      .rows[0];
    expect(row.is_online).toBe(true);
    expect(row.last_seen_at).toBeTruthy();

    await setOffline(provider.id);
    row = (await query(`SELECT is_online FROM providers WHERE id = $1`, [provider.id])).rows[0];
    expect(row.is_online).toBe(false);
  });

  it("detects stale online providers", async () => {
    const { provider } = await completeRegistration("03070000002");
    await setOnline(provider.id);
    await query(`UPDATE providers SET last_seen_at = now() - interval '5 minutes' WHERE id = $1`, [
      provider.id,
    ]);

    const presence = buildPresence({
      id: provider.id,
      is_online: true,
      last_seen_at: new Date(Date.now() - 5 * 60_000).toISOString(),
    });
    expect(presence.isStale).toBe(true);

    const swept = await sweepStaleProviders();
    expect(swept).toBeGreaterThanOrEqual(1);
  });

  it("GET /admin/providers/online requires admin", async () => {
    const res = await api().get("/api/v1/admin/providers/online");
    expect(res.status).toBe(401);
  });

  it("lists online approved providers for admin", async () => {
    const { provider } = await completeRegistration("03070000003");
    await query(
      `UPDATE providers SET status_id = (SELECT id FROM statuses WHERE code = $2 LIMIT 1),
       is_online = true, last_seen_at = now()
       WHERE id = $1`,
      [provider.id, PROVIDER_STATUS.APPROVED],
    );

    const token = await adminAuth();
    const res = await api()
      .get("/api/v1/admin/providers/online")
      .set("Authorization", `Bearer ${token}`);
    expect(res.status).toBe(200);
    expect(res.body.data.some((p) => p.id === provider.id)).toBe(true);
    expect(res.body.data[0].presence.isOnline).toBe(true);
  });

  it("touchLastSeen refreshes timestamp", async () => {
    const { provider } = await completeRegistration("03070000004");
    await setOnline(provider.id);
    const before = (await query(`SELECT last_seen_at FROM providers WHERE id = $1`, [provider.id]))
      .rows[0].last_seen_at;
    await new Promise((r) => setTimeout(r, 20));
    await touchLastSeen(provider.id);
    const after = (await query(`SELECT last_seen_at FROM providers WHERE id = $1`, [provider.id]))
      .rows[0].last_seen_at;
    expect(new Date(after).getTime()).toBeGreaterThanOrEqual(new Date(before).getTime());
  });
});
