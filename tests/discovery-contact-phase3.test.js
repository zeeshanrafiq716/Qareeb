import { beforeEach, describe, expect, it } from "vitest";
import { query } from "../src/db/pool.js";
import { setOnline } from "../src/modules/presence.service.js";
import { processLocationUpdate } from "../src/modules/location.service.js";
import { completeRegistration, adminAuth, api } from "./helpers.js";
import { resetDb } from "./setup.js";

const SESSION = "test-session-abc12345";

async function approveAndGoOnline(providerId) {
  const adminToken = await adminAuth();
  await api()
    .post(`/api/v1/admin/providers/${providerId}/approve`)
    .set("Authorization", `Bearer ${adminToken}`)
    .send({});
  await setOnline(providerId);
  await processLocationUpdate(providerId, 31.52, 74.3587);
}

describe("Phase 3 direct contact + funnel", () => {
  beforeEach(async () => {
    await resetDb();
  });

  it("profile exposes tel/wa.me actions and share location (4-tap flow)", async () => {
    const { provider } = await completeRegistration("03092000001");
    await approveAndGoOnline(provider.id);

    const cats = await api().get("/api/v1/discovery/categories");
    expect(cats.status).toBe(200);

    const search = await api()
      .get(
        "/api/v1/discovery/search?latitude=31.52&longitude=74.35&radiusKm=10&sessionId=" +
          SESSION,
      )
      .set("X-Customer-Session", SESSION);
    expect(search.status).toBe(200);
    expect(search.body.data.list.some((p) => p.id === provider.id)).toBe(true);
    expect(search.body.data.list[0].phone).toBeUndefined();

    const profile = await api().get(
      `/api/v1/discovery/providers/${provider.providerId}?latitude=31.52&longitude=74.35&sessionId=${SESSION}`,
    );
    expect(profile.status).toBe(200);
    const contact = profile.body.data.contact;
    expect(contact.hostedByQareeb).toBe(false);
    expect(contact.actions.call.url).toMatch(/^tel:\+/);
    expect(contact.actions.whatsapp.url).toMatch(/^https:\/\/wa\.me\//);
    expect(contact.actions.shareLocation.whatsappUrl).toContain("wa.me");
    expect(contact.actions.shareLocation.mapsUrl).toContain("31.52");
  });

  it("records funnel events and call log on call_click", async () => {
    const { provider } = await completeRegistration("03092000002");
    await approveAndGoOnline(provider.id);

    const res = await api()
      .post("/api/v1/discovery/events")
      .send({
        sessionId: SESSION,
        event: "call_click",
        providerPublicId: provider.providerId,
        latitude: 31.52,
        longitude: 74.35,
      });
    expect(res.status).toBe(201);

    const { rows: events } = await query(
      `SELECT event_type FROM customer_funnel_events WHERE provider_id = $1`,
      [provider.id],
    );
    expect(events.some((e) => e.event_type === "call_click")).toBe(true);

    const { rows: calls } = await query(
      `SELECT id FROM call_logs WHERE provider_id = $1`,
      [provider.id],
    );
    expect(calls.length).toBe(1);
  });

  it("admin funnel summary aggregates views and clicks", async () => {
    const { provider } = await completeRegistration("03092000003");
    await approveAndGoOnline(provider.id);
    const adminToken = await adminAuth();

    await api()
      .get("/api/v1/discovery/search?latitude=31.52&longitude=74.35&radiusKm=10")
      .set("X-Customer-Session", SESSION);

    await api().get(
      `/api/v1/discovery/providers/${provider.providerId}?latitude=31.52&longitude=74.35&sessionId=${SESSION}`,
    );

    await api().post("/api/v1/discovery/events").send({
      sessionId: SESSION,
      event: "whatsapp_click",
      providerPublicId: provider.providerId,
    });

    const funnel = await api()
      .get(`/api/v1/admin/providers/${provider.id}/funnel`)
      .set("Authorization", `Bearer ${adminToken}`);
    expect(funnel.status).toBe(200);
    expect(funnel.body.data.funnel.listImpressions).toBeGreaterThan(0);
    expect(funnel.body.data.funnel.profileViews).toBeGreaterThan(0);
    expect(funnel.body.data.funnel.whatsappClicks).toBe(1);
  });
});
