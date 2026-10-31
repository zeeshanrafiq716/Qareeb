import { describe, expect, it } from "vitest";
import { api } from "./helpers.js";
import {
  checkDocumentExpiry,
  generateKycAccessToken,
  processKycWebhook,
} from "../src/modules/kyc.service.js";

describe("KYC & Document Verification Engine", () => {
  it("generates a valid KYC applicant token in sandbox mode", async () => {
    const tokenData = await generateKycAccessToken({
      providerId: "test-provider-101",
      levelName: "provider-verification",
    });

    expect(tokenData).toBeDefined();
    expect(tokenData.token).toMatch(/^sb_token_/);
    expect(tokenData.mode).toBe("sandbox");
    expect(tokenData.config.livenessDetection).toBe(true);
    expect(tokenData.config.antiSpoofing).toBe(true);
  });

  it("accurately detects and rejects expired documents", () => {
    const pastDate = "2020-01-01";
    expect(() => checkDocumentExpiry(pastDate)).toThrowError(/expired/);

    const futureDate = "2030-12-31";
    const validReport = checkDocumentExpiry(futureDate);
    expect(validReport.isExpired).toBe(false);
    expect(validReport.checked).toBe(true);
  });

  it("handles Sumsub webhook approved callback", async () => {
    const payload = {
      type: "applicantReviewed",
      applicantId: "app-12345",
      reviewResult: {
        reviewAnswer: "GREEN",
      },
      reviewStatus: "completed",
    };

    const result = await processKycWebhook({ payload });
    expect(result.handled).toBe(true);
    expect(result.verificationDecision).toBe("APPROVED");
  });

  it("handles Sumsub webhook rejected callback with reason", async () => {
    const payload = {
      type: "applicantReviewed",
      applicantId: "app-67890",
      reviewResult: {
        reviewAnswer: "RED",
        rejectLabels: ["DOCUMENT_PAGE_NOT_ORIGINAL", "GRAPHIC_EDITOR_SUSPECTED"],
      },
      reviewStatus: "completed",
    };

    const result = await processKycWebhook({ payload });
    expect(result.handled).toBe(true);
    expect(result.verificationDecision).toBe("REJECTED");
    expect(result.rejectionReason).toContain("DOCUMENT_PAGE_NOT_ORIGINAL");
  });

  it("POST /api/v1/provider/kyc/webhook responds with 200 OK", async () => {
    const res = await api()
      .post("/api/v1/provider/kyc/webhook")
      .send({
        type: "applicantReviewed",
        applicantId: "app-test-webhook",
        reviewResult: { reviewAnswer: "GREEN" },
      });

    expect(res.status).toBe(200);
    expect(res.body.data.handled).toBe(true);
  });
});
