import { beforeEach, describe, expect, it } from "vitest";
import { query } from "../src/db/pool.js";
import { setOnline } from "../src/modules/presence.service.js";
import { processLocationUpdate } from "../src/modules/location.service.js";
import { completeRegistration, adminAuth, api } from "./helpers.js";
import { resetDb } from "./setup.js";

async function approveAndGoOnline(providerId) {
  const adminToken = await adminAuth();
  await api()
    .post(`/api/v1/admin/providers/${providerId}/approve`)
    .set("Authorization", `Bearer ${adminToken}`)
    .send({});
  await setOnline(providerId);
  await processLocationUpdate(providerId, 31.52, 74.3587);
}

describe("Phase 3 customer discovery", () => {
  beforeEach(async () => {
    await resetDb();
  });

  it("lists discovery categories", async () => {
    const res = await api().get("/api/v1/discovery/categories");
    expect(res.status).toBe(200);
    expect(res.body.data.length).toBeGreaterThan(0);
  });

  it("search returns list + map with rating, verified, availability", async () => {
    const { provider } = await completeRegistration("03091000001");
    await query(`UPDATE providers SET rating_avg = 4.5, rating_count = 10 WHERE id = $1`, [
      provider.id,
    ]);
    await approveAndGoOnline(provider.id);

    const res = await api().get(
      "/api/v1/discovery/search?latitude=31.5204&longitude=74.3587&radiusKm=10",
    );
    expect(res.status).toBe(200);
    expect(res.body.data.list.length).toBeGreaterThan(0);
    expect(res.body.data.map.markers.length).toBe(res.body.data.list.length);

    const item = res.body.data.list.find((p) => p.id === provider.id);
    expect(item.rating.average).toBe(4.5);
    expect(item.verified).toBe(true);
    expect(item.availability.isAvailable).toBe(true);
    expect(item.approximateLocation).toBeTruthy();
    expect(item.photoUrl).toBeTruthy();
  });

  it("filters by categorySlug", async () => {
    const { provider } = await completeRegistration("03091000002");
    const cats = await api().get("/api/v1/discovery/categories");
    const slug = cats.body.data[0].slug;
    await approveAndGoOnline(provider.id);

    const res = await api().get(
      `/api/v1/discovery/search?latitude=31.52&longitude=74.35&radiusKm=20&categorySlug=${slug}`,
    );
    expect(res.body.data.list.some((p) => p.id === provider.id)).toBe(true);
  });

  it("public provider profile by QRB id", async () => {
    const { provider } = await completeRegistration("03091000003");
    await approveAndGoOnline(provider.id);

    const res = await api().get(
      `/api/v1/discovery/providers/${provider.providerId}?latitude=31.52&longitude=74.35`,
    );
    expect(res.status).toBe(200);
    expect(res.body.data.name).toBeTruthy();
    expect(res.body.data.verified).toBe(true);
    expect(res.body.data.distanceMeters).toBeGreaterThanOrEqual(0);
    expect(res.body.data.approximateLocation).toBeTruthy();
  });
});
