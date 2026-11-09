import { env } from "../config/env.js";
import { PROVIDER_STATUS } from "../config/constants.js";
import { query } from "../db/pool.js";
import { ForbiddenError } from "../utils/AppError.js";
import { presenceStore } from "../redis/presenceStore.js";
import { AppError } from "../utils/AppError.js";
import { distanceMeters, isSignificantMovement } from "../utils/geo.js";

function nextAllowedSeconds(lastGateMs) {
  if (!lastGateMs) return 0;
  const elapsed = Date.now() - lastGateMs;
  const wait = env.LOCATION_MIN_INTERVAL_SECONDS * 1000 - elapsed;
  return wait > 0 ? Math.ceil(wait / 1000) : 0;
}

export function isLocationFresh(updatedAt) {
  if (!updatedAt) return false;
  const ageMs = Date.now() - new Date(updatedAt).getTime();
  return ageMs <= env.LOCATION_MAX_INTERVAL_SECONDS * 1000;
}

export async function processLocationUpdate(providerId, latitude, longitude, address = null, city = null) {
  const lat = Number(latitude);
  const lng = Number(longitude);
  if (!Number.isFinite(lat) || !Number.isFinite(lng)) {
    throw new AppError(400, "Invalid coordinates", "INVALID_COORDINATES");
  }
  if (lat < -90 || lat > 90 || lng < -180 || lng > 180) {
    throw new AppError(400, "Coordinates out of range", "INVALID_COORDINATES");
  }

  const lastGate = await presenceStore.getLocationGate(providerId);
  const waitSec = nextAllowedSeconds(lastGate);
  const previous = await presenceStore.getLocation(providerId);

  if (waitSec > 0 && previous) {
    const moved = isSignificantMovement(
      previous.latitude,
      previous.longitude,
      lat,
      lng,
      env.LOCATION_SIGNIFICANT_MOVEMENT_METERS,
    );
    if (!moved) {
      return {
        accepted: false,
        reason: "interval_throttle",
        nextAllowedInSeconds: waitSec,
        policy: {
          minIntervalSeconds: env.LOCATION_MIN_INTERVAL_SECONDS,
          maxIntervalSeconds: env.LOCATION_MAX_INTERVAL_SECONDS,
          significantMovementMeters: env.LOCATION_SIGNIFICANT_MOVEMENT_METERS,
        },
      };
    }
  }

  // Derive human-readable city from coordinates or address if not directly passed
  let resolvedCity = city;
  if (!resolvedCity || resolvedCity.startsWith("GPS (") || resolvedCity.toLowerCase() === "pending") {
    if (lat >= 24.0 && lat <= 25.5 && lng >= 46.0 && lng <= 47.5) resolvedCity = "Riyadh";
    else if (lat >= 21.0 && lat <= 22.0 && lng >= 38.8 && lng <= 39.8) resolvedCity = "Jeddah";
    else if (lat >= 26.0 && lat <= 26.8 && lng >= 49.5 && lng <= 50.5) resolvedCity = "Dammam";
    else if (lat >= 21.2 && lat <= 21.7 && lng >= 39.6 && lng <= 40.1) resolvedCity = "Makkah";
    else if (lat >= 24.2 && lat <= 24.8 && lng >= 39.3 && lng <= 39.9) resolvedCity = "Madinah";
    else if (lat >= 31.0 && lat <= 32.0 && lng >= 74.0 && lng <= 74.6) resolvedCity = "Lahore";
    else if (lat >= 24.7 && lat <= 25.1 && lng >= 66.8 && lng <= 67.4) resolvedCity = "Karachi";
    else if (lat >= 33.5 && lat <= 33.8 && lng >= 72.9 && lng <= 73.3) resolvedCity = "Islamabad";
    else if (lat >= 31.3 && lat <= 31.6 && lng >= 73.0 && lng <= 73.2) resolvedCity = "Faisalabad";
    else if (address && !address.toLowerCase().includes("current location") && !address.toLowerCase().includes("gps")) {
      resolvedCity = address.split(",")[0].trim();
    } else {
      resolvedCity = `${lat.toFixed(4)}, ${lng.toFixed(4)}`;
    }
  }

  const resolvedAddress = address || (resolvedCity.includes(",") ? `GPS: ${resolvedCity}` : resolvedCity);
  const now = new Date().toISOString();

  await query(
    `INSERT INTO locations (provider_id, latitude, longitude, address, city, location_updated_at)
     VALUES ($1, $2, $3, $4, $5, now())
     ON CONFLICT (provider_id) DO UPDATE
     SET latitude = EXCLUDED.latitude,
         longitude = EXCLUDED.longitude,
         address = COALESCE(EXCLUDED.address, locations.address),
         city = COALESCE(EXCLUDED.city, locations.city),
         location_updated_at = now()`,
    [providerId, lat, lng, resolvedAddress, resolvedCity],
  );

  await presenceStore.setLocation(providerId, { latitude: lat, longitude: lng, updatedAt: now });
  await presenceStore.setLocationGate(providerId, Date.now());
  await presenceStore.touch(providerId);
  await query(`UPDATE providers SET last_seen_at = now() WHERE id = $1`, [providerId]);

  return {
    accepted: true,
    updatedAt: now,
    city: resolvedCity,
    address: resolvedAddress,
    nextAllowedInSeconds: env.LOCATION_MIN_INTERVAL_SECONDS,
    policy: {
      minIntervalSeconds: env.LOCATION_MIN_INTERVAL_SECONDS,
      maxIntervalSeconds: env.LOCATION_MAX_INTERVAL_SECONDS,
      significantMovementMeters: env.LOCATION_SIGNIFICANT_MOVEMENT_METERS,
    },
  };
}

export async function getProviderExactLocation(providerId) {
  const redisLoc = await presenceStore.getLocation(providerId);
  if (redisLoc) return redisLoc;

  const { rows } = await query(
    `SELECT latitude, longitude, location_updated_at FROM locations WHERE provider_id = $1`,
    [providerId],
  );
  if (!rows[0]?.latitude) return null;
  return {
    latitude: Number(rows[0].latitude),
    longitude: Number(rows[0].longitude),
    updatedAt: rows[0].location_updated_at,
  };
}
