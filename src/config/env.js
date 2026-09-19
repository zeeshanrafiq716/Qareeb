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
  isTest: (process.env.NODE_ENV || "development") === "test",
  isProd: process.env.NODE_ENV === "production" || process.env.NODE_ENV === "staging",
};

export function databaseUrlFor(name) {
  const url = new URL(env.DATABASE_URL);
  url.pathname = `/${name}`;
  return url.toString();
}
