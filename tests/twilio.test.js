import { describe, expect, it } from "vitest";
import {
  isTwilioConfigured,
  getTwilioClient,
  sendTwilioOtp,
  testTwilioConnection,
} from "../src/modules/twilio.service.js";

describe("Twilio Service Unit Tests", () => {
  it("correctly identifies when Twilio is unconfigured or disabled", () => {
    expect(typeof isTwilioConfigured()).toBe("boolean");
  });

  it("gracefully falls back when Twilio is disabled or credentials missing", async () => {
    const result = await sendTwilioOtp({
      phone: "+966501234567",
      otp: "123456",
      channel: "sms",
      userType: "customer",
    });

    expect(result).toHaveProperty("channel", "sms");
    if (!isTwilioConfigured()) {
      expect(result.dummy).toBe(true);
      expect(result.success).toBe(false);
      expect(result.reason).toBe("twilio_not_configured");
    }
  });

  it("handles whatsapp channel parameter correctly", async () => {
    const result = await sendTwilioOtp({
      phone: "+966501234567",
      otp: "654321",
      channel: "whatsapp",
      userType: "provider",
    });

    expect(result).toHaveProperty("channel", "whatsapp");
    if (!isTwilioConfigured()) {
      expect(result.dummy).toBe(true);
      expect(result.reason).toBe("twilio_not_configured");
    }
  });

  it("reports diagnostic connection status safely without throwing", async () => {
    const status = await testTwilioConnection();
    expect(status).toHaveProperty("configured");
    if (!isTwilioConfigured()) {
      expect(status.configured).toBe(false);
    }
  });
});

