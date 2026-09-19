import { beforeEach, describe, expect, it } from "vitest";
import { env } from "../src/config/env.js";
import { PROVIDER_STATUS } from "../src/config/constants.js";
import {
  adminAuth,
  api,
  completeRegistration,
  loginAdmin,
} from "./helpers.js";
import { resetDb } from "./setup.js";

describe("admin authentication and provider management", () => {
  beforeEach(async () => {
    await resetDb();
  });

  it("rejects invalid admin credentials", async () => {
    const res = await api().post("/api/v1/admin/auth/login").send({
      email: env.ADMIN_EMAIL,
      password: "wrong-password",
    });
    expect(res.status).toBe(401);
  });

  it("logs in a seeded admin", async () => {
    const res = await loginAdmin();
    expect(res.status).toBe(200);
    expect(res.body.data.token).toBeTruthy();
    expect(res.body.data.admin.email).toBe(env.ADMIN_EMAIL);
  });

  it("protects admin provider listing", async () => {
    const res = await api().get("/api/v1/admin/providers");
    expect(res.status).toBe(401);
  });

  it("lists providers and returns details", async () => {
    const created = await completeRegistration("03030000001");
    const token = await adminAuth();
    const list = await api().get("/api/v1/admin/providers").set("Authorization", `Bearer ${token}`);
    expect(list.status).toBe(200);
    expect(list.body.meta.total).toBe(1);
    expect(list.body.data[0].status).toBe(PROVIDER_STATUS.PENDING_VERIFICATION);

    const details = await api()
      .get(`/api/v1/admin/providers/${created.provider.id}`)
      .set("Authorization", `Bearer ${token}`);
    expect(details.status).toBe(200);
    expect(details.body.data.providerId).toMatch(/^QRB-/);
    expect(details.body.data.verification.documentType).toBe("cnic");
    expect(details.body.data.location.city).toBe("Lahore");
    expect(details.body.data.statusHistory.length).toBeGreaterThanOrEqual(3);
  });

  it("approves a pending provider", async () => {
    const created = await completeRegistration("03030000002");
    const token = await adminAuth();
    const res = await api()
      .post(`/api/v1/admin/providers/${created.provider.id}/approve`)
      .set("Authorization", `Bearer ${token}`)
      .send({ reason: "Documents verified" });
    expect(res.status).toBe(200);
    expect(res.body.data.status).toBe(PROVIDER_STATUS.APPROVED);
  });

  it("rejects a pending provider with a reason", async () => {
    const created = await completeRegistration("03030000003");
    const token = await adminAuth();
    const res = await api()
      .post(`/api/v1/admin/providers/${created.provider.id}/reject`)
      .set("Authorization", `Bearer ${token}`)
      .send({ reason: "CNIC is blurry" });
    expect(res.status).toBe(200);
    expect(res.body.data.status).toBe(PROVIDER_STATUS.REJECTED);
    expect(res.body.data.statusReason).toBe("CNIC is blurry");
  });

  it("suspends and reinstates an approved provider", async () => {
    const created = await completeRegistration("03030000004");
    const token = await adminAuth();
    const id = created.provider.id;

    await api().post(`/api/v1/admin/providers/${id}/approve`).set("Authorization", `Bearer ${token}`).send({});

    const suspended = await api()
      .post(`/api/v1/admin/providers/${id}/suspend`)
      .set("Authorization", `Bearer ${token}`)
      .send({ reason: "Policy violation" });
    expect(suspended.body.data.status).toBe(PROVIDER_STATUS.SUSPENDED);

    const reinstated = await api()
      .post(`/api/v1/admin/providers/${id}/reinstate`)
      .set("Authorization", `Bearer ${token}`)
      .send({ reason: "Issue resolved" });
    expect(reinstated.body.data.status).toBe(PROVIDER_STATUS.APPROVED);
  });

  it("does not approve a provider that is still pending profile", async () => {
    const { provider } = await (await import("./helpers.js")).registerProvider("03030000005");
    const token = await adminAuth();
    const res = await api()
      .post(`/api/v1/admin/providers/${provider.id}/approve`)
      .set("Authorization", `Bearer ${token}`)
      .send({});
    expect(res.status).toBe(409);
    expect(res.body.error.code).toBe("INVALID_STATUS_TRANSITION");
  });
});
