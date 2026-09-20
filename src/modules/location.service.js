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

export async function processLocationUpdate(providerId, latitude, longitude) {
  const status = await query(
    `SELECT s.code FROM providers p JOIN statuses s ON s.id = p.status_id WHERE p.id = $1`,
    [providerId],
  );
  if (status.rows[0]?.code !== PROVIDER_STATUS.APPROVED) {
    throw new ForbiddenError("Only approved providers can publish live location");
  }

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

  const now = new Date().toISOString();
  await query(
    `INSERT INTO locations (provider_id, latitude, longitude, location_updated_at)
     VALUES ($1, $2, $3, now())
     ON CONFLICT (provider_id) DO UPDATE
     SET latitude = EXCLUDED.latitude,
         longitude = EXCLUDED.longitude,
         location_updated_at = now()`,
    [providerId, lat, lng],
  );

  await presenceStore.setLocation(providerId, { latitude: lat, longitude: lng, updatedAt: now });
  await presenceStore.setLocationGate(providerId, Date.now());
  await presenceStore.touch(providerId);

  return {
    accepted: true,
    updatedAt: now,
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
