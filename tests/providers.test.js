import { beforeEach, describe, expect, it } from "vitest";
import { PROVIDER_STATUS } from "../src/config/constants.js";
import {
  api,
  registerProvider,
  submitDocument,
  submitProfile,
} from "./helpers.js";
import { resetDb } from "./setup.js";

describe("provider profile and verification", () => {
  beforeEach(async () => {
    await resetDb();
  });

  it("requires name and category on profile update", async () => {
    const { token } = await registerProvider("03020000001");
    const res = await api()
      .put("/api/v1/providers/me/profile")
      .set("Authorization", `Bearer ${token}`)
      .send({ name: "A" });
    expect(res.status).toBe(400);
    expect(res.body.error.code).toBe("VALIDATION_ERROR");
  });

  it("saves profile, photo and location", async () => {
    const { token } = await registerProvider("03020000002");
    const res = await submitProfile(token);
    expect(res.status).toBe(200);
    expect(res.body.data.name).toBe("Ali Plumber");
    expect(res.body.data.category).toBeTruthy();
    expect(res.body.data.photoUrl).toMatch(/\/uploads\/providers\//);
    expect(res.body.data.location.city).toBe("Lahore");
    expect(res.body.data.status).toBe(PROVIDER_STATUS.PENDING_PROFILE);
  });

  it("rejects verification before profile is complete", async () => {
    const { token } = await registerProvider("03020000003");
    const res = await submitDocument(token);
    expect(res.status).toBe(400);
    expect(res.body.error.code).toBe("PROFILE_INCOMPLETE");
  });

  it("submitting a document moves status to pending_verification", async () => {
    const { token } = await registerProvider("03020000004");
    await submitProfile(token);
    const res = await submitDocument(token);
    expect(res.status).toBe(201);
    expect(res.body.data.status).toBe(PROVIDER_STATUS.PENDING_VERIFICATION);
    expect(res.body.data.verification.documentType).toBe("cnic");
    expect(res.body.data.verification.status).toBe("pending");
  });
});
