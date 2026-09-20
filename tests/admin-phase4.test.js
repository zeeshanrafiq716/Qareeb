import { beforeEach, describe, expect, it } from "vitest";
import { query } from "../src/db/pool.js";
import { setOnline } from "../src/modules/presence.service.js";
import { processLocationUpdate } from "../src/modules/location.service.js";
import { completeRegistration, adminAuth, api } from "./helpers.js";
import { resetDb } from "./setup.js";

describe("Phase 4 admin panel APIs", () => {
  beforeEach(async () => {
    await resetDb();
  });

  it("looks up provider by QRB id and phone", async () => {
    const { provider } = await completeRegistration("03094000001");
    const token = await adminAuth();

    const byId = await api()
      .get(`/api/v1/admin/providers/lookup?q=${provider.providerId}`)
      .set("Authorization", `Bearer ${token}`);
    expect(byId.status).toBe(200);
    expect(byId.body.data.id).toBe(provider.id);

    const byPhone = await api()
      .get("/api/v1/admin/providers/lookup?q=03094000001")
      .set("Authorization", `Bearer ${token}`);
    expect(byPhone.status).toBe(200);
    expect(byPhone.body.data.providerId).toBe(provider.providerId);
  });

  it("returns admin live map with online/offline/suspended states", async () => {
    const { provider } = await completeRegistration("03094000002");
    const token = await adminAuth();
    await api()
      .post(`/api/v1/admin/providers/${provider.id}/approve`)
      .set("Authorization", `Bearer ${token}`)
      .send({});
    await setOnline(provider.id);
    await processLocationUpdate(provider.id, 31.52, 74.3587);

    const map = await api()
      .get("/api/v1/admin/providers/map")
      .set("Authorization", `Bearer ${token}`);
    expect(map.status).toBe(200);
    const marker = map.body.data.markers.find((m) => m.id === provider.id);
    expect(marker.mapStatus).toBe("online");
    expect(marker.location.latitude).toBeCloseTo(31.52, 2);

    await api()
      .post(`/api/v1/admin/providers/${provider.id}/suspend`)
      .set("Authorization", `Bearer ${token}`)
      .send({ reason: "Test suspend" });

    const map2 = await api()
      .get("/api/v1/admin/providers/map")
      .set("Authorization", `Bearer ${token}`);
    const suspended = map2.body.data.markers.find((m) => m.id === provider.id);
    expect(suspended.mapStatus).toBe("suspended");
  });

  it("lists platform funnel analytics and global call logs", async () => {
    const { provider } = await completeRegistration("03094000003");
    const token = await adminAuth();
    await api()
      .post(`/api/v1/admin/providers/${provider.id}/approve`)
      .set("Authorization", `Bearer ${token}`)
      .send({});

    await api().post("/api/v1/discovery/events").send({
      sessionId: "phase4-test-session",
      event: "call_click",
      providerPublicId: provider.providerId,
    });

    const analytics = await api()
      .get("/api/v1/admin/analytics/funnel?days=7")
      .set("Authorization", `Bearer ${token}`);
    expect(analytics.status).toBe(200);
    expect(analytics.body.data.totals.callClicks).toBeGreaterThan(0);

    const logs = await api()
      .get(`/api/v1/admin/call-logs?providerId=${provider.id}`)
      .set("Authorization", `Bearer ${token}`);
    expect(logs.status).toBe(200);
    expect(logs.body.data.length).toBeGreaterThan(0);

    const funnel = await api()
      .get(`/api/v1/admin/providers/${provider.id}/funnel`)
      .set("Authorization", `Bearer ${token}`);
    expect(funnel.body.data.funnel.callClicks).toBe(1);
  });

  it("search list supports exact QRB filter", async () => {
    const { provider } = await completeRegistration("03094000004");
    const token = await adminAuth();
    const list = await api()
      .get(`/api/v1/admin/providers?search=${provider.providerId}`)
      .set("Authorization", `Bearer ${token}`);
    expect(list.body.data.length).toBe(1);
    expect(list.body.data[0].providerId).toBe(provider.providerId);
  });
});
