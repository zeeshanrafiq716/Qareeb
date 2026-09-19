import { beforeEach, describe, expect, it } from "vitest";
import { PROVIDER_STATUS } from "../src/config/constants.js";
import { env } from "../src/config/env.js";
import {
  adminAuth,
  api,
  completeRegistration,
  registerProvider,
  submitDocument,
  submitProfile,
} from "./helpers.js";
import { resetDb } from "./setup.js";

describe("Phase 1 end-to-end flow", () => {
  beforeEach(async () => {
    await resetDb();
  });

  it("registers → OTP → profile/document → pending → admin approve", async () => {
    const phone = "03061234567";
    const { token, provider, verified } = await registerProvider(phone);
    expect(verified.status).toBe(200);
    expect(provider.status).toBe(PROVIDER_STATUS.PENDING_PROFILE);
    expect(provider.providerId).toBe("QRB-100001");

    const profile = await submitProfile(token, { name: "Hassan Electrician" });
    expect(profile.status).toBe(200);
    expect(profile.body.data.status).toBe(PROVIDER_STATUS.PENDING_PROFILE);

    const document = await submitDocument(token);
    expect(document.status).toBe(201);
    expect(document.body.data.status).toBe(PROVIDER_STATUS.PENDING_VERIFICATION);

    const adminToken = await adminAuth();
    const pendingList = await api()
      .get("/api/v1/admin/providers?status=pending_verification")
      .set("Authorization", `Bearer ${adminToken}`);
    expect(pendingList.body.data).toHaveLength(1);

    const approved = await api()
      .post(`/api/v1/admin/providers/${provider.id}/approve`)
      .set("Authorization", `Bearer ${adminToken}`)
      .send({ reason: "ID matched" });
    expect(approved.status).toBe(200);
    expect(approved.body.data.status).toBe(PROVIDER_STATUS.APPROVED);

    const me = await api().get("/api/v1/providers/me").set("Authorization", `Bearer ${token}`);
    expect(me.body.data.status).toBe(PROVIDER_STATUS.APPROVED);
    expect(me.body.data.name).toBe("Hassan Electrician");
  });

  it("allows a rejected provider to resubmit and become pending again", async () => {
    const { token, provider } = await completeRegistration("03060000002");
    const adminToken = await adminAuth();

    const rejected = await api()
      .post(`/api/v1/admin/providers/${provider.id}/reject`)
      .set("Authorization", `Bearer ${adminToken}`)
      .send({ reason: "Photo is not clear" });
    expect(rejected.body.data.status).toBe(PROVIDER_STATUS.REJECTED);

    const resubmitted = await submitDocument(token, "passport");
    expect(resubmitted.status).toBe(201);
    expect(resubmitted.body.data.status).toBe(PROVIDER_STATUS.PENDING_VERIFICATION);
    expect(resubmitted.body.data.verification.documentType).toBe("passport");
  });

  it("records a call log against an approved provider", async () => {
    const { provider } = await completeRegistration("03060000003");
    const adminToken = await adminAuth();
    await api()
      .post(`/api/v1/admin/providers/${provider.id}/approve`)
      .set("Authorization", `Bearer ${adminToken}`)
      .send({});

    const created = await api()
      .post(`/api/v1/admin/providers/${provider.id}/call-logs`)
      .set("Authorization", `Bearer ${adminToken}`)
      .send({ callerPhone: "+923001112223", notes: "Phase 1 relationship check" });
    expect(created.status).toBe(201);

    const list = await api()
      .get(`/api/v1/admin/providers/${provider.id}/call-logs`)
      .set("Authorization", `Bearer ${adminToken}`);
    expect(list.body.data).toHaveLength(1);
    expect(list.body.data[0].caller_phone).toBe("+923001112223");
  });

  it("uses the seeded admin email from env", () => {
    expect(env.ADMIN_EMAIL).toBe("admin@qareeb.app");
  });
});
