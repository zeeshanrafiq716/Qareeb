import { beforeEach, describe, expect, it } from "vitest";
import { query } from "../src/db/pool.js";
import { PROVIDER_STATUS } from "../src/config/constants.js";
import {
  api,
  registerProvider,
  requestOtp,
  verifyOtp,
} from "./helpers.js";
import { resetDb } from "./setup.js";

describe("provider OTP registration", () => {
  beforeEach(async () => {
    await resetDb();
  });

  it("rejects an invalid phone number", async () => {
    const res = await requestOtp("0000000000");
    expect(res.status).toBe(400);
    expect(res.body.error.code).toBe("INVALID_PHONE");
  });

  it("sends OTP, creates provider, and generates unique provider ID", async () => {
    const res = await requestOtp("03001234567");
    expect(res.status).toBe(200);
    expect(res.body.data.otp).toBe("123456");
    expect(res.body.data.phone).toBe("+923001234567");

    const { rows } = await query(
      `SELECT p.public_id, s.code
       FROM providers p JOIN statuses s ON s.id = p.status_id
       WHERE p.phone = '+923001234567'`,
    );
    expect(rows[0].public_id).toBe("QRB-100001");
    expect(rows[0].code).toBe(PROVIDER_STATUS.PENDING_OTP);
  });

  it("rejects a wrong OTP", async () => {
    await requestOtp("03001112233");
    const res = await verifyOtp("03001112233", "000000");
    expect(res.status).toBe(400);
    expect(res.body.error.code).toBe("OTP_INVALID");
  });

  it("verifies OTP and moves provider to pending_profile", async () => {
    const { verified, provider, token } = await registerProvider("03009876543");
    expect(verified.status).toBe(200);
    expect(token).toBeTruthy();
    expect(provider.providerId).toMatch(/^QRB-\d+$/);
    expect(provider.status).toBe(PROVIDER_STATUS.PENDING_PROFILE);
    expect(provider.phone).toBe("+923009876543");
  });

  it("blocks /providers/me without a token", async () => {
    const res = await api().get("/api/v1/providers/me");
    expect(res.status).toBe(401);
  });

  it("returns the current provider profile after OTP", async () => {
    const { token, provider } = await registerProvider("03111222333");
    const res = await api().get("/api/v1/providers/me").set("Authorization", `Bearer ${token}`);
    expect(res.status).toBe(200);
    expect(res.body.data.providerId).toBe(provider.providerId);
    expect(res.body.data.status).toBe(PROVIDER_STATUS.PENDING_PROFILE);
  });
});
