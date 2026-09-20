import { beforeEach, describe, expect, it } from "vitest";
import { env } from "../src/config/env.js";
import { api, completeRegistration, adminAuth } from "./helpers.js";
import { resetDb } from "./setup.js";

describe("Phase 5 infrastructure", () => {
  beforeEach(async () => {
    await resetDb();
  });

  it("returns emptyState when no providers online", async () => {
    const res = await api().get(
      "/api/v1/discovery/search?latitude=31.52&longitude=74.35&radiusKm=5",
    );
    expect(res.status).toBe(200);
    expect(res.body.data.list).toEqual([]);
    expect(res.body.meta.emptyState.screen).toBe("empty_map");
    expect(res.body.meta.emptyState.title.ar).toBeTruthy();
  });

  it("registers provider FCM device token", async () => {
    const { token } = await completeRegistration("03095000001");
    const res = await api()
      .put("/api/v1/providers/me/push-token")
      .set("Authorization", `Bearer ${token}`)
      .send({
        token: "fcm-test-token-abcdefghijklmnopqrstuvwxyz",
        platform: "android",
        appVersion: "1.0.0",
      });
    expect(res.status).toBe(200);
    expect(res.body.data.platform).toBe("android");
  });

  it("readiness endpoint reports database", async () => {
    const res = await api().get("/health/ready");
    expect([200, 503]).toContain(res.status);
    expect(res.body.data.checks.database).toBeDefined();
    expect(res.body.data.phase).toBe(5);
  });

  it("enforces OTP cooldown on rapid re-request", async () => {
    const prev = env.OTP_REQUEST_COOLDOWN_SECONDS;
    env.OTP_REQUEST_COOLDOWN_SECONDS = 60;
    try {
      await api().post("/api/v1/auth/otp/request").send({ phone: "03095000002" });
      const again = await api().post("/api/v1/auth/otp/request").send({ phone: "03095000002" });
      expect(again.status).toBe(429);
      expect(again.body.error.code).toBe("OTP_COOLDOWN");
    } finally {
      env.OTP_REQUEST_COOLDOWN_SECONDS = prev;
    }
  });

  it("admin push returns 503 when FCM disabled", async () => {
    const { provider } = await completeRegistration("03095000003");
    const adminToken = await adminAuth();
    const res = await api()
      .post("/api/v1/admin/notifications/send")
      .set("Authorization", `Bearer ${adminToken}`)
      .send({
        providerId: provider.id,
        title: "Test",
        body: "Hello",
      });
    expect(res.status).toBe(503);
  });
});
