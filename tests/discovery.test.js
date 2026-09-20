import { beforeEach, describe, expect, it } from "vitest";
import { PROVIDER_STATUS } from "../src/config/constants.js";
import { query } from "../src/db/pool.js";
import { setOnline } from "../src/modules/presence.service.js";
import { processLocationUpdate } from "../src/modules/location.service.js";
import { completeRegistration, adminAuth, api } from "./helpers.js";
import { resetDb } from "./setup.js";

describe("customer discovery privacy", () => {
  beforeEach(async () => {
    await resetDb();
  });

  it("returns approximate location only, never exact", async () => {
    const { provider, token } = await completeRegistration("03081000001");
    const adminToken = await adminAuth();
    await api()
      .post(`/api/v1/admin/providers/${provider.id}/approve`)
      .set("Authorization", `Bearer ${adminToken}`)
      .send({});

    await setOnline(provider.id);
    await processLocationUpdate(provider.id, 31.52, 74.3587);

    const res = await api().get(
      "/api/v1/discovery/nearby?latitude=31.5204&longitude=74.3587&radiusKm=10",
    );
    expect(res.status).toBe(200);
    expect(res.body.data.length).toBeGreaterThan(0);

    const item = res.body.data.find((p) => p.id === provider.id);
    expect(item).toBeTruthy();
    expect(item.approximateLocation).toBeTruthy();
    expect(item.approximateLocation.accuracyRadiusMeters).toBe(300);
    expect(item.distanceMeters).toBeGreaterThanOrEqual(0);

    const exactLat = 31.52;
    const approxLat = item.approximateLocation.latitude;
    expect(Math.abs(approxLat - exactLat)).toBeLessThan(0.01);
    expect(approxLat).not.toBe(exactLat);
  });

  it("excludes offline providers", async () => {
    const { provider } = await completeRegistration("03081000002");
    await query(
      `UPDATE providers SET status_id = (SELECT id FROM statuses WHERE code = $2 LIMIT 1)
       WHERE id = $1`,
      [provider.id, PROVIDER_STATUS.APPROVED],
    );
    await processLocationUpdate(provider.id, 31.52, 74.35);

    const res = await api().get(
      "/api/v1/discovery/nearby?latitude=31.52&longitude=74.35&radiusKm=5",
    );
    const found = res.body.data.find((p) => p.id === provider.id);
    expect(found).toBeUndefined();
  });
});
