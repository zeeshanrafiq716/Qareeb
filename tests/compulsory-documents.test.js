import { beforeEach, describe, expect, it } from "vitest";
import { PROVIDER_STATUS } from "../src/config/constants.js";
import {
  adminAuth,
  api,
  pngBuffer,
  registerProvider,
  submitProfile,
} from "./helpers.js";
import { resetDb } from "./setup.js";

describe("Compulsory documents backend enforcement", () => {
  beforeEach(async () => {
    await resetDb();
  });

  it("enforces all compulsory documents on backend and blocks approval if incomplete", async () => {
    const { token, provider } = await registerProvider("03099998888");
    await submitProfile(token);

    // 1. Upload only Iqama
    const iqamaRes = await api()
      .post("/api/v1/providers/me/verification")
      .set("Authorization", `Bearer ${token}`)
      .field("documentType", "iqama")
      .attach("document", pngBuffer, "iqama.png");

    expect(iqamaRes.status).toBe(201);
    expect(iqamaRes.body.data.documentsStatus.allCompulsorySubmitted).toBe(false);
    expect(iqamaRes.body.data.documentsStatus.missingCompulsoryDocuments).toContain("registration");
    expect(iqamaRes.body.data.documentsStatus.missingCompulsoryDocuments).toContain("license");

    // 2. /me/verification/check-all returns 400 because registration and license are missing
    const checkFail = await api()
      .post("/api/v1/providers/me/verification/check-all")
      .set("Authorization", `Bearer ${token}`);
    expect(checkFail.status).toBe(400);
    expect(checkFail.body.error.code).toBe("COMPULSORY_DOCUMENTS_MISSING");

    // 3. Admin attempts to approve while compulsory documents are missing -> rejected
    const adminToken = await adminAuth();
    const adminApproveFail = await api()
      .post(`/api/v1/admin/providers/${provider.id}/approve`)
      .set("Authorization", `Bearer ${adminToken}`)
      .send({ reason: "Premature approval test" });
    expect([400, 409]).toContain(adminApproveFail.status);

    // 4. Upload Vehicle Registration
    const regRes = await api()
      .post("/api/v1/providers/me/verification")
      .set("Authorization", `Bearer ${token}`)
      .field("documentType", "registration")
      .attach("document", pngBuffer, "registration.png");
    expect(regRes.status).toBe(201);
    expect(regRes.body.data.documentsStatus.allCompulsorySubmitted).toBe(false);
    expect(regRes.body.data.documentsStatus.missingCompulsoryDocuments).toEqual([
      "license",
      "vehicle_front",
      "vehicle_rear",
      "vehicle_left_side",
      "vehicle_right_side",
    ]);

    // 5. Upload Driving Licence
    const licRes = await api()
      .post("/api/v1/providers/me/verification")
      .set("Authorization", `Bearer ${token}`)
      .field("documentType", "driving_licence")
      .attach("document", pngBuffer, "licence.png");
    expect(licRes.status).toBe(201);
    expect(licRes.body.data.documentsStatus.allCompulsorySubmitted).toBe(false);
    expect(licRes.body.data.documentsStatus.missingCompulsoryDocuments).toEqual([
      "vehicle_front",
      "vehicle_rear",
      "vehicle_left_side",
      "vehicle_right_side",
    ]);

    // 6. Upload 4 Compulsory Vehicle Photos
    for (const view of [
      "vehicle_front",
      "vehicle_rear",
      "vehicle_left_side",
      "vehicle_right_side",
    ]) {
      const vRes = await api()
        .post("/api/v1/providers/me/verification")
        .set("Authorization", `Bearer ${token}`)
        .field("documentType", view)
        .attach("document", pngBuffer, `${view}.png`);
      expect(vRes.status).toBe(201);
    }

    // 7. Verify all compulsory docs & photos are now complete
    const checkSuccess = await api()
      .post("/api/v1/providers/me/verification/check-all")
      .set("Authorization", `Bearer ${token}`);
    expect(checkSuccess.status).toBe(200);
    expect(checkSuccess.body.data.allCompulsorySubmitted).toBe(true);
    expect(checkSuccess.body.data.missingCompulsoryDocuments).toEqual([]);

    // 8. Admin can now approve the provider
    const adminApproveSuccess = await api()
      .post(`/api/v1/admin/providers/${provider.id}/approve`)
      .set("Authorization", `Bearer ${adminToken}`)
      .send({ reason: "All compulsory documents verified" });
    expect(adminApproveSuccess.status).toBe(200);
    expect(adminApproveSuccess.body.data.status).toBe(PROVIDER_STATUS.APPROVED);
  });
});
