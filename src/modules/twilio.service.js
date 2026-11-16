import { env } from "../config/env.js";
import { logger } from "../logger.js";
import { normalizePhone } from "../utils/phone.js";

let cachedClient = null;
let twilioFactory = null;

async function getTwilioFactory() {
  if (twilioFactory) return twilioFactory;
  try {
    const mod = await import("twilio");
    twilioFactory = mod.default || mod;
    return twilioFactory;
  } catch (err) {
    logger.warn({ err: err.message }, "[Twilio] Optional twilio package not found");
    return null;
  }
}

/**
 * Returns true if Twilio integration is enabled and has required credentials.
 */
export function isTwilioConfigured() {
  return Boolean(
    env.TWILIO_ENABLED &&
      env.TWILIO_ACCOUNT_SID &&
      env.TWILIO_AUTH_TOKEN &&
      (env.TWILIO_PHONE_NUMBER || env.TWILIO_MESSAGING_SERVICE_SID || env.TWILIO_VERIFY_SERVICE_SID),
  );
}

/**
 * Get or initialize the Twilio REST API client.
 */
export async function getTwilioClient() {
  if (!env.TWILIO_ACCOUNT_SID || !env.TWILIO_AUTH_TOKEN) {
    return null;
  }
  if (!cachedClient) {
    const twilio = await getTwilioFactory();
    if (!twilio) return null;
    cachedClient = twilio(env.TWILIO_ACCOUNT_SID, env.TWILIO_AUTH_TOKEN);
  }
  return cachedClient;
}

/**
 * Format bilingual OTP message body for SMS and WhatsApp
 */
function buildOtpMessage(otp, userType = "user") {
  const roleLabel =
    userType === "provider"
      ? "Provider / الكابتن"
      : userType === "customer"
        ? "Customer / العميل"
        : "Qareeb / قريب";

  return `[Qareeb ${roleLabel}] Your verification code is: ${otp}\n\nرمز التحقق الخاص بك في تطبيق قريب هو: ${otp}\n(صالح لمدة ${env.OTP_EXPIRES_MINUTES} دقائق)`;
}

/**
 * Ensure phone number is formatted for WhatsApp (prefixed with "whatsapp:")
 */
function formatWhatsAppNumber(phone) {
  const normalized = normalizePhone(phone);
  return normalized.startsWith("whatsapp:") ? normalized : `whatsapp:${normalized}`;
}

/**
 * Send OTP to customer or provider via Twilio (SMS or WhatsApp)
 *
 * @param {Object} options
 * @param {string} options.phone - E.164 phone number
 * @param {string} options.otp - 6-digit verification code
 * @param {"sms" | "whatsapp"} [options.channel="sms"] - Delivery channel
 * @param {"customer" | "provider" | "user"} [options.userType="user"]
 * @returns {Promise<{ success: boolean, sid?: string, channel: string, error?: string, dummy?: boolean }>}
 */
export async function sendTwilioOtp({ phone, otp, channel = "sms", userType = "user" }) {
  const normalizedPhone = normalizePhone(phone);

  if (!isTwilioConfigured()) {
    logger.info(
      { phone: normalizedPhone, channel, userType },
      "[Twilio] SMS dispatch bypassed (TWILIO_ENABLED=false or credentials unconfigured).",
    );
    return {
      success: false,
      dummy: true,
      channel,
      reason: "twilio_not_configured",
    };
  }

  const client = await getTwilioClient();
  if (!client) {
    logger.warn("[Twilio] Failed to initialize Twilio client with provided credentials.");
    return { success: false, channel, error: "twilio_client_unavailable" };
  }

  const body = buildOtpMessage(otp, userType);

  try {
    if (channel === "whatsapp") {
      const fromNumber = env.TWILIO_WHATSAPP_NUMBER || env.TWILIO_PHONE_NUMBER;
      if (!fromNumber) {
        throw new Error("TWILIO_WHATSAPP_NUMBER or TWILIO_PHONE_NUMBER required for WhatsApp delivery");
      }

      const formattedFrom = formatWhatsAppNumber(fromNumber);
      const formattedTo = formatWhatsAppNumber(normalizedPhone);

      logger.info({ to: formattedTo, from: formattedFrom }, "[Twilio] Dispatching WhatsApp verification code");

      const message = await client.messages.create({
        body,
        from: formattedFrom,
        to: formattedTo,
      });

      logger.info(
        { sid: message.sid, status: message.status, to: formattedTo },
        "[Twilio] WhatsApp message sent successfully",
      );

      return {
        success: true,
        sid: message.sid,
        status: message.status,
        channel: "whatsapp",
      };
    }

    // Standard SMS Delivery
    const messagePayload = {
      body,
      to: normalizedPhone,
    };

    if (env.TWILIO_MESSAGING_SERVICE_SID) {
      messagePayload.messagingServiceSid = env.TWILIO_MESSAGING_SERVICE_SID;
    } else if (env.TWILIO_PHONE_NUMBER) {
      messagePayload.from = env.TWILIO_PHONE_NUMBER;
    } else {
      throw new Error("Either TWILIO_PHONE_NUMBER or TWILIO_MESSAGING_SERVICE_SID must be configured");
    }

    logger.info({ to: normalizedPhone }, "[Twilio] Dispatching SMS OTP verification code");

    const message = await client.messages.create(messagePayload);

    logger.info(
      { sid: message.sid, status: message.status, to: normalizedPhone },
      "[Twilio] SMS sent successfully",
    );

    return {
      success: true,
      sid: message.sid,
      status: message.status,
      channel: "sms",
    };
  } catch (error) {
    logger.error(
      {
        err: error.message,
        code: error.code,
        status: error.status,
        phone: normalizedPhone,
        channel,
      },
      "[Twilio] Failed to deliver OTP message",
    );

    return {
      success: false,
      channel,
      error: error.message,
      code: error.code,
    };
  }
}

/**
 * Test Twilio connectivity and account details
 */
export async function testTwilioConnection({ testPhone, channel = "sms" } = {}) {
  if (!isTwilioConfigured()) {
    return {
      configured: false,
      message: "Twilio is not configured or disabled (TWILIO_ENABLED=false).",
    };
  }

  const client = await getTwilioClient();
  try {
    const account = await client.api.v2010.accounts(env.TWILIO_ACCOUNT_SID).fetch();

    let sendResult = null;
    if (testPhone) {
      sendResult = await sendTwilioOtp({
        phone: testPhone,
        otp: "999888",
        channel,
        userType: "test",
      });
    }

    return {
      configured: true,
      accountFriendlyName: account.friendlyName,
      status: account.status,
      type: account.type,
      testSend: sendResult,
    };
  } catch (error) {
    return {
      configured: false,
      error: error.message,
      code: error.code,
    };
  }
}

