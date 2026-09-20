import { env } from "../config/env.js";
import { logger } from "../logger.js";

/** Optional webhook (Slack/Discord/custom) for unhandled 5xx — set MONITORING_WEBHOOK_URL. */
export async function reportErrorToMonitoring(payload) {
  if (!env.MONITORING_WEBHOOK_URL) return;
  try {
    await fetch(env.MONITORING_WEBHOOK_URL, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        source: "qareeb-api",
        environment: env.NODE_ENV,
        ...payload,
      }),
      signal: AbortSignal.timeout(5000),
    });
  } catch (error) {
    logger.warn({ err: error }, "Monitoring webhook failed");
  }
}
