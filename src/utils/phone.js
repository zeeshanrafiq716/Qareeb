import { AppError } from "./AppError.js";

export function normalizePhone(value) {
  if (!value || typeof value !== "string") {
    throw new AppError(400, "Phone number is required", "INVALID_PHONE");
  }

  let phone = value.trim().replace(/[\s-()]/g, "");
  if (phone.startsWith("00")) phone = `+${phone.slice(2)}`;
  if (/^0\d{10}$/.test(phone)) phone = `+92${phone.slice(1)}`;
  if (/^92\d{10}$/.test(phone)) phone = `+${phone}`;
  if (!phone.startsWith("+") && /^\d{10,15}$/.test(phone)) phone = `+${phone}`;

  if (!/^\+[1-9]\d{9,14}$/.test(phone)) {
    throw new AppError(400, "Enter a valid phone number", "INVALID_PHONE");
  }

  return phone;
}
