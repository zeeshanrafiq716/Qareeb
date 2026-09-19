import request from "supertest";
import { createApp } from "../src/app.js";
import { env } from "../src/config/env.js";
import { query } from "../src/db/pool.js";

export const app = createApp();

export const pngBuffer = Buffer.from(
  "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==",
  "base64",
);

export function api() {
  return request(app);
}

export async function loginAdmin() {
  const response = await request(app).post("/api/v1/admin/auth/login").send({
    email: env.ADMIN_EMAIL,
    password: env.ADMIN_PASSWORD,
  });
  return response;
}

export async function adminAuth() {
  const response = await loginAdmin();
  return response.body.data.token;
}

export async function requestOtp(phone) {
  return request(app).post("/api/v1/auth/otp/request").send({ phone });
}

export async function verifyOtp(phone, otp) {
  return request(app).post("/api/v1/auth/otp/verify").send({ phone, otp });
}

export async function registerProvider(phone = "03001234567") {
  const otpRes = await requestOtp(phone);
  const otp = otpRes.body.data.otp;
  const verified = await verifyOtp(phone, otp);
  return {
    phone,
    otp,
    token: verified.body.data.token,
    provider: verified.body.data.provider,
    otpRes,
    verified,
  };
}

export async function firstCategoryId() {
  const { rows } = await query(`SELECT id FROM categories WHERE is_enabled = true ORDER BY name LIMIT 1`);
  return rows[0].id;
}

export async function submitProfile(token, overrides = {}) {
  const categoryId = overrides.categoryId || (await firstCategoryId());
  return request(app)
    .put("/api/v1/providers/me/profile")
    .set("Authorization", `Bearer ${token}`)
    .field("name", overrides.name || "Ali Plumber")
    .field("categoryId", categoryId)
    .field("address", overrides.address || "Shop 12, Main Bazaar")
    .field("city", overrides.city || "Lahore")
    .field("latitude", String(overrides.latitude ?? 31.5204))
    .field("longitude", String(overrides.longitude ?? 74.3587))
    .attach("photo", pngBuffer, "photo.png");
}

export async function submitDocument(token, documentType = "cnic") {
  return request(app)
    .post("/api/v1/providers/me/verification")
    .set("Authorization", `Bearer ${token}`)
    .field("documentType", documentType)
    .attach("document", pngBuffer, "cnic.png");
}

export async function completeRegistration(phone = "03001234567") {
  const registered = await registerProvider(phone);
  const profile = await submitProfile(registered.token);
  const verification = await submitDocument(registered.token);
  return { ...registered, profile, verification };
}
