import crypto from "node:crypto";
import { env } from "../config/env.js";

/**
 * Deterministic approximate point within ~radius of true location (privacy for customers).
 * Same providerId → same offset until salt rotates (daily).
 */
export function approximateLocation(latitude, longitude, providerId) {
  const day = new Date().toISOString().slice(0, 10);
  const hash = crypto
    .createHash("sha256")
    .update(`${providerId}:${day}:${env.PRIVACY_LOCATION_SALT}`)
    .digest();

  const angle = (hash.readUInt32BE(0) / 0xffffffff) * 2 * Math.PI;
  const dist = (hash.readUInt32BE(4) / 0xffffffff) * env.PRIVACY_MASK_RADIUS_METERS;

  const latRad = (latitude * Math.PI) / 180;
  const dLat = (dist * Math.cos(angle)) / 111320;
  const dLon = (dist * Math.sin(angle)) / (111320 * Math.cos(latRad));

  return {
    latitude: Number((latitude + dLat).toFixed(6)),
    longitude: Number((longitude + dLon).toFixed(6)),
    accuracyRadiusMeters: env.PRIVACY_MASK_RADIUS_METERS,
  };
}

export function customerProviderView(providerRow, distanceMeters) {
  const lat = Number(providerRow.latitude);
  const lng = Number(providerRow.longitude);
  const approx =
    Number.isFinite(lat) && Number.isFinite(lng)
      ? approximateLocation(lat, lng, providerRow.id)
      : null;

  return {
    id: providerRow.id,
    providerId: providerRow.public_id,
    name: providerRow.name,
    category: providerRow.category_id
      ? { id: providerRow.category_id, name: providerRow.category_name }
      : null,
    photoUrl: providerRow.photo_url,
    isOnline: Boolean(providerRow.is_online),
    approximateLocation: approx,
    distanceMeters: Math.round(distanceMeters),
  };
}
