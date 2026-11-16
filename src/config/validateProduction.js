import { env } from "./env.js";
import { logger } from "../logger.js";

export function validateProductionConfig() {
  if (env.NODE_ENV !== "production") return;

  const issues = [];
  if (env.JWT_SECRET === "dev-secret-change-me" || env.JWT_SECRET.length < 32) {
    issues.push("JWT_SECRET must be a long random value in production");
  }
  if (env.OTP_RETURN_IN_RESPONSE) {
    issues.push("OTP_RETURN_IN_RESPONSE should be false in production");
  }
  if (env.OTP_STATIC_CODE) {
    issues.push("OTP_STATIC_CODE should be empty in production");
  }
  if (env.ADMIN_PASSWORD === "QareebAdmin@123") {
    issues.push("Change default ADMIN_PASSWORD in production");
  }
  if (env.CORS_ORIGIN === "*") {
    issues.push("Consider restricting CORS_ORIGIN in production");
  }

  if (issues.length) {
    logger.warn({ issues }, "Production configuration warnings detected (server continuing startup safely)");
  }
}
