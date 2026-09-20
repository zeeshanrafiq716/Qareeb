import { beforeEach, describe, expect, it } from "vitest";
import { PROVIDER_STATUS } from "../src/config/constants.js";
import { query } from "../src/db/pool.js";
import { processLocationUpdate } from "../src/modules/location.service.js";
import { completeRegistration, adminAuth, api } from "./helpers.js";
import { resetDb } from "./setup.js";

async function approveProvider(providerId) {
  const token = await adminAuth();
  await api()
    .post(`/api/v1/admin/providers/${providerId}/approve`)
    .set("Authorization", `Bearer ${token}`)
    .send({ reason: "test" });
}

describe("battery-efficient location updates", () => {
  beforeEach(async () => {
    await resetDb();
  });

  it("accepts first location update", async () => {
    const { provider, token } = await completeRegistration("03080000001");
    await approveProvider(provider.id);

    const res = await api()
      .put("/api/v1/providers/me/location")
      .set("Authorization", `Bearer ${token}`)
      .send({ latitude: 31.5204, longitude: 74.3587 });
    expect(res.status).toBe(200);
    expect(res.body.data.accepted).toBe(true);
  });

  it("throttles frequent updates unless significant movement", async () => {
    const { provider } = await completeRegistration("03080000002");
    await approveProvider(provider.id);

    const first = await processLocationUpdate(provider.id, 31.52, 74.35);
    expect(first.accepted).toBe(true);

    const second = await processLocationUpdate(provider.id, 31.5201, 74.3501);
    expect(second.accepted).toBe(false);
    expect(second.reason).toBe("interval_throttle");

    const moved = await processLocationUpdate(provider.id, 31.53, 74.36);
    expect(moved.accepted).toBe(true);
  });
});
