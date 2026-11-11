import { beforeEach, describe, expect, it } from "vitest";
import { query } from "../src/db/pool.js";
import { api, registerProvider, requestOtp, verifyOtp } from "./helpers.js";
import { resetDb } from "./setup.js";

describe("Store Compliance & Account Deletion Security", () => {
  beforeEach(async () => {
    await resetDb();
  });

  it("provisions Apple/Google store reviewer account with static OTP 123456", async () => {
    const reviewerPhone = "+966500000000";
    const reqRes = await requestOtp(reviewerPhone);
    expect(reqRes.status).toBe(200);
    expect(reqRes.body.data.otp).toBe("123456");

    const verifyRes = await verifyOtp(reviewerPhone, "123456");
    expect(verifyRes.status).toBe(200);
    expect(verifyRes.body.data.token).toBeTruthy();
    expect(verifyRes.body.data.provider.phone).toBe(reviewerPhone);
  });

  it("allows authenticated provider to self-delete their account (Apple 5.1.1(v) compliance)", async () => {
    const { token, provider } = await registerProvider("03129998877");
    expect(token).toBeTruthy();

    // Verify provider exists initially
    const checkBefore = await api()
      .get("/api/v1/provider/me")
      .set("Authorization", `Bearer ${token}`);
    expect(checkBefore.status).toBe(200);

    // Call DELETE /api/v1/provider/me
    const deleteRes = await api()
      .delete("/api/v1/provider/me")
      .set("Authorization", `Bearer ${token}`);

    expect(deleteRes.status).toBe(200);
    expect(deleteRes.body.data.success).toBe(true);

    // Subsequent call should fail because account is deleted
    const checkAfter = await api()
      .get("/api/v1/provider/me")
      .set("Authorization", `Bearer ${token}`);
    expect(checkAfter.status).toBe(401);
    expect(checkAfter.body.error.code).toBe("ACCOUNT_DELETED");

    // Ensure database record is deleted
    const { rows } = await query("SELECT id FROM providers WHERE id = $1", [provider.id]);
    expect(rows.length).toBe(0);
  });
});
