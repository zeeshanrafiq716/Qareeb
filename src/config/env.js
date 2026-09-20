import fs from "node:fs";
import path from "node:path";
import dotenv from "dotenv";

const root = process.cwd();
const envFile =
  process.env.NODE_ENV === "test"
    ? ".env.test"
    : process.env.NODE_ENV === "staging"
      ? ".env.staging"
      : ".env";

const envPath = path.join(root, envFile);
if (fs.existsSync(envPath)) {
  dotenv.config({ path: envPath, override: false, quiet: true });
} else {
  dotenv.config({ quiet: true });
}

function required(name, fallback) {
  const value = process.env[name] ?? fallback;
  if (value === undefined || value === "") {
    throw new Error(`Missing required environment variable: ${name}`);
  }
  return value;
}

function bool(name, fallback = false) {
  const value = process.env[name];
  if (value === undefined || value === "") return fallback;
  return ["1", "true", "yes", "on"].includes(String(value).toLowerCase());
}

function integer(name, fallback) {
  const value = Number(process.env[name] ?? fallback);
  if (!Number.isFinite(value)) {
    throw new Error(`Environment variable ${name} must be a number`);
  }
  return value;
}

export const env = {
  NODE_ENV: process.env.NODE_ENV || "development",
  PORT: integer("PORT", 3000),
  DATABASE_URL: required("DATABASE_URL", "postgres://postgres:postgres@127.0.0.1:5433/qareeb"),
  DATABASE_URL_TEST: process.env.DATABASE_URL_TEST || "postgres://postgres:postgres@127.0.0.1:5433/qareeb_test",
  EMBEDDED_POSTGRES: bool("EMBEDDED_POSTGRES", true),
  EMBEDDED_POSTGRES_PORT: integer("EMBEDDED_POSTGRES_PORT", 5433),
  JWT_SECRET: required("JWT_SECRET", "dev-secret-change-me"),
  JWT_PROVIDER_EXPIRES_IN: process.env.JWT_PROVIDER_EXPIRES_IN || "7d",
  JWT_ADMIN_EXPIRES_IN: process.env.JWT_ADMIN_EXPIRES_IN || "12h",
  ADMIN_EMAIL: (process.env.ADMIN_EMAIL || "admin@qareeb.app").toLowerCase(),
  ADMIN_PASSWORD: process.env.ADMIN_PASSWORD || "QareebAdmin@123",
  ADMIN_NAME: process.env.ADMIN_NAME || "Qareeb Admin",
  OTP_EXPIRES_MINUTES: integer("OTP_EXPIRES_MINUTES", 10),
  OTP_MAX_ATTEMPTS: integer("OTP_MAX_ATTEMPTS", 5),
  OTP_RETURN_IN_RESPONSE: bool("OTP_RETURN_IN_RESPONSE", true),
  OTP_STATIC_CODE: process.env.OTP_STATIC_CODE || "",
  UPLOAD_DIR: process.env.UPLOAD_DIR || "uploads",
  MAX_PHOTO_MB: integer("MAX_PHOTO_MB", 5),
  MAX_DOCUMENT_MB: integer("MAX_DOCUMENT_MB", 10),
  LOG_LEVEL: process.env.LOG_LEVEL || "info",
  CORS_ORIGIN: process.env.CORS_ORIGIN || "*",
  AUTO_MIGRATE: bool("AUTO_MIGRATE", true),
  AUTO_SEED: bool("AUTO_SEED", true),
  PRESENCE_STALE_SECONDS: integer("PRESENCE_STALE_SECONDS", 90),
  PRESENCE_SWEEP_INTERVAL_MS: integer("PRESENCE_SWEEP_INTERVAL_MS", 60_000),
  REDIS_URL: process.env.REDIS_URL || "redis://127.0.0.1:6379",
  REDIS_ENABLED: bool("REDIS_ENABLED", true),
  LOCATION_MIN_INTERVAL_SECONDS: integer("LOCATION_MIN_INTERVAL_SECONDS", 30),
  LOCATION_MAX_INTERVAL_SECONDS: integer("LOCATION_MAX_INTERVAL_SECONDS", 60),
  LOCATION_SIGNIFICANT_MOVEMENT_METERS: integer("LOCATION_SIGNIFICANT_MOVEMENT_METERS", 75),
  PRIVACY_MASK_RADIUS_METERS: integer("PRIVACY_MASK_RADIUS_METERS", 300),
  PRIVACY_LOCATION_SALT: process.env.PRIVACY_LOCATION_SALT || "qareeb-privacy-salt",
  RATE_LIMIT_ENABLED: bool("RATE_LIMIT_ENABLED", true),
  API_RATE_LIMIT_PER_MINUTE: integer("API_RATE_LIMIT_PER_MINUTE", 120),
  OTP_RATE_LIMIT_WINDOW_SECONDS: integer("OTP_RATE_LIMIT_WINDOW_SECONDS", 3600),
  OTP_RATE_LIMIT_PER_IP: integer("OTP_RATE_LIMIT_PER_IP", 15),
  OTP_RATE_LIMIT_PER_PHONE: integer("OTP_RATE_LIMIT_PER_PHONE", 5),
  OTP_VERIFY_RATE_LIMIT_PER_IP: integer("OTP_VERIFY_RATE_LIMIT_PER_IP", 30),
  OTP_REQUEST_COOLDOWN_SECONDS: integer("OTP_REQUEST_COOLDOWN_SECONDS", 60),
  ADMIN_LOGIN_RATE_LIMIT: integer("ADMIN_LOGIN_RATE_LIMIT", 10),
  FCM_ENABLED: bool("FCM_ENABLED", false),
  FCM_PROJECT_ID: process.env.FCM_PROJECT_ID || "",
  FCM_SERVICE_ACCOUNT_JSON: (() => {
    const raw = process.env.FCM_SERVICE_ACCOUNT_JSON;
    if (!raw) return null;
    try {
      return JSON.parse(raw);
    } catch {
      return null;
    }
  })(),
  MONITORING_WEBHOOK_URL: process.env.MONITORING_WEBHOOK_URL || "",
  isTest: (process.env.NODE_ENV || "development") === "test",
  isProd: process.env.NODE_ENV === "production" || process.env.NODE_ENV === "staging",
};

export function databaseUrlFor(name) {
  const url = new URL(env.DATABASE_URL);
  url.pathname = `/${name}`;
  return url.toString();
}
