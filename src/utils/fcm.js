import crypto from "node:crypto";
import { env } from "../config/env.js";
import { logger } from "../logger.js";

function base64Url(input) {
  return Buffer.from(input)
    .toString("base64")
    .replace(/=/g, "")
    .replace(/\+/g, "-")
    .replace(/\//g, "_");
}

async function getFcmAccessToken() {
  const sa = env.FCM_SERVICE_ACCOUNT_JSON;
  if (!sa?.client_email || !sa?.private_key) {
    throw new Error("FCM service account not configured");
  }
  const now = Math.floor(Date.now() / 1000);
  const header = base64Url(JSON.stringify({ alg: "RS256", typ: "JWT" }));
  const claim = base64Url(
    JSON.stringify({
      iss: sa.client_email,
      sub: sa.client_email,
      aud: "https://oauth2.googleapis.com/token",
      iat: now,
      exp: now + 3600,
      scope: "https://www.googleapis.com/auth/firebase.messaging",
    }),
  );
  const unsigned = `${header}.${claim}`;
  const sign = crypto.createSign("RSA-SHA256");
  sign.update(unsigned);
  sign.end();
  const signature = base64Url(sign.sign(sa.private_key));
  const jwt = `${unsigned}.${signature}`;

  const tokenRes = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  });
  const tokenJson = await tokenRes.json();
  if (!tokenRes.ok) {
    throw new Error(tokenJson.error_description || "FCM OAuth failed");
  }
  return tokenJson.access_token;
}

/** FCM HTTP v1 (preferred). Logs only when FCM_ENABLED=false. */
export async function sendFcmMessage({ token, title, body, data = {} }) {
  if (!env.FCM_ENABLED) {
    logger.info({ tokenPrefix: token.slice(0, 10), title }, "FCM skipped (FCM_ENABLED=false)");
    return { mocked: true };
  }

  const projectId = env.FCM_PROJECT_ID;
  if (!projectId) throw new Error("FCM_PROJECT_ID is required");

  const accessToken = await getFcmAccessToken();
  const res = await fetch(
    `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${accessToken}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        message: {
          token,
          notification: { title, body },
          data: Object.fromEntries(
            Object.entries(data).map(([k, v]) => [k, String(v ?? "")]),
          ),
        },
      }),
    },
  );
  const json = await res.json();
  if (!res.ok) {
    throw new Error(json.error?.message || "FCM send failed");
  }
  return json;
}
