import { env } from "../config/env.js";
import { PROVIDER_STATUS, VERIFICATION_STATUS } from "../config/constants.js";
import { query } from "../db/pool.js";
import { isPostgisEnabled } from "../db/postgis.js";
import { isLocationFresh } from "./location.service.js";
import { presenceStore } from "../redis/presenceStore.js";
import { approximateLocation } from "./privacy.service.js";
import { NotFoundError } from "../utils/AppError.js";
import { distanceMeters } from "../utils/geo.js";
import { slugify } from "../utils/helpers.js";
import { buildDirectContactActions } from "../utils/contactActions.js";
import { FUNNEL_EVENT, recordFunnelEvent, recordListImpressions } from "./funnel.service.js";
import { buildCustomerEmptyState } from "../utils/discoveryEmptyState.js";

const PROVIDER_DISCOVERY_SELECT = `
  p.id, p.public_id, p.name, p.photo_url, p.is_online, p.last_seen_at,
  p.rating_avg, p.rating_count,
  c.id AS category_id, c.name AS category_name, c.slug AS category_slug,
  l.latitude, l.longitude, l.location_updated_at, l.city,
  ver.verification_status
`;

const VERIFICATION_LATERAL = `
  LEFT JOIN LATERAL (
    SELECT s2.code AS verification_status
    FROM verifications v
    JOIN statuses s2 ON s2.id = v.status_id
    WHERE v.provider_id = p.id
    ORDER BY v.created_at DESC
    LIMIT 1
  ) ver ON true
`;

export async function resolveCategoryFilter({ categoryId, categorySlug }) {
  if (categoryId) {
    const { rows } = await query(
      `SELECT id, name, slug FROM categories WHERE id = $1 AND is_enabled = true`,
      [categoryId],
    );
    if (!rows[0]) return null;
    return rows[0];
  }
  if (categorySlug) {
    const slug = slugify(categorySlug);
    const { rows } = await query(
      `SELECT id, name, slug FROM categories WHERE slug = $1 AND is_enabled = true`,
      [slug],
    );
    if (!rows[0]) return null;
    return rows[0];
  }
  return null;
}

export function buildAvailability(row, redisOnline) {
  const locationFresh = isLocationFresh(row.location_updated_at);
  const isOnline = Boolean(redisOnline || row.is_online);
  const isAvailable = isOnline && locationFresh;

  return {
    isAvailable,
    isOnline,
    locationFresh,
    label: isAvailable ? "Available now" : isOnline ? "Online — updating location" : "Offline",
  };
}

export function buildCustomerDiscoveryCard(row, distanceM, redisOnline) {
  const lat = Number(row.latitude);
  const lng = Number(row.longitude);
  const approx =
    Number.isFinite(lat) && Number.isFinite(lng)
      ? approximateLocation(lat, lng, row.id)
      : null;

  const verified = row.verification_status === VERIFICATION_STATUS.APPROVED;
  const ratingAvg = Number(row.rating_avg ?? 0);
  const ratingCount = Number(row.rating_count ?? 0);

  return {
    id: row.id,
    providerId: row.public_id,
    name: row.name,
    photoUrl: row.photo_url,
    category: row.category_id
      ? { id: row.category_id, name: row.category_name, slug: row.category_slug }
      : null,
    distanceMeters: Math.round(distanceM),
    approximateLocation: approx,
    rating: {
      average: ratingAvg,
      count: ratingCount,
      display: ratingCount > 0 ? ratingAvg.toFixed(1) : "New",
    },
    verified,
    badges: {
      verified,
      available: buildAvailability(row, redisOnline).isAvailable,
    },
    availability: buildAvailability(row, redisOnline),
  };
}

async function queryNearbyRows({ latitude, longitude, radiusKm, categoryId, limit }) {
  const lat = Number(latitude);
  const lng = Number(longitude);
  const radiusM = Math.min(50, Math.max(0.5, Number(radiusKm) || 5)) * 1000;
  const safeLimit = Math.min(50, Math.max(1, Number(limit) || 20));

  if (isPostgisEnabled()) {
    const params = [lat, lng, radiusM, PROVIDER_STATUS.APPROVED];
    let categorySql = "";
    if (categoryId) {
      params.push(categoryId);
      categorySql = `AND p.category_id = $${params.length}`;
    }
    params.push(safeLimit);
    const limitIdx = params.length;
    const { rows } = await query(
      `SELECT ${PROVIDER_DISCOVERY_SELECT},
              ST_Distance(l.geom, ST_SetSRID(ST_MakePoint($2, $1), 4326)::geography) AS distance_m
       FROM providers p
       JOIN statuses s ON s.id = p.status_id
       JOIN categories c ON c.id = p.category_id AND c.is_enabled = true
       JOIN locations l ON l.provider_id = p.id AND l.geom IS NOT NULL
       ${VERIFICATION_LATERAL}
       WHERE s.code = $4 AND p.is_online = true
         ${categorySql}
         AND ST_DWithin(l.geom, ST_SetSRID(ST_MakePoint($2, $1), 4326)::geography, $3)
       ORDER BY distance_m ASC
       LIMIT $${limitIdx}`,
      params,
    );
    return { rows, radiusM, engine: "postgis" };
  }

  const params = [lat, lng, radiusM, PROVIDER_STATUS.APPROVED];
  let categorySql = "";
  if (categoryId) {
    params.push(categoryId);
    categorySql = `AND p.category_id = $${params.length}`;
  }
  params.push(safeLimit);
  const limitIdx = params.length;
  const { rows } = await query(
    `SELECT * FROM (
       SELECT ${PROVIDER_DISCOVERY_SELECT},
              (6371000 * acos(
                LEAST(1, GREATEST(-1,
                  cos(radians($1)) * cos(radians(l.latitude)) *
                  cos(radians(l.longitude) - radians($2)) +
                  sin(radians($1)) * sin(radians(l.latitude))
                ))
              )) AS distance_m
       FROM providers p
       JOIN statuses s ON s.id = p.status_id
       JOIN categories c ON c.id = p.category_id AND c.is_enabled = true
       JOIN locations l ON l.provider_id = p.id
       ${VERIFICATION_LATERAL}
       WHERE s.code = $4 AND p.is_online = true
         AND l.latitude IS NOT NULL AND l.longitude IS NOT NULL
         ${categorySql}
     ) nearby
     WHERE distance_m <= $3
     ORDER BY distance_m ASC
     LIMIT $${limitIdx}`,
    params,
  );
  return { rows, radiusM, engine: "haversine" };
}

export async function searchDiscovery(input) {
  const category = await resolveCategoryFilter(input);
  if ((input.categoryId || input.categorySlug) && !category) {
    return {
      list: [],
      map: { center: { latitude: input.latitude, longitude: input.longitude }, markers: [] },
      meta: {
        count: 0,
        radiusKm: input.radiusKm ?? 5,
        category: null,
        geoEngine: isPostgisEnabled() ? "postgis" : "haversine",
        privacy: { approximateOnly: true, maskRadiusMeters: env.PRIVACY_MASK_RADIUS_METERS },
        emptyState: buildCustomerEmptyState({
          count: 0,
          radiusKm: input.radiusKm ?? 5,
          category: null,
        }),
      },
    };
  }

  const { rows, radiusM, engine } = await queryNearbyRows({
    ...input,
    categoryId: category?.id,
  });

  const list = [];
  for (const row of rows) {
    if (!isLocationFresh(row.location_updated_at)) continue;
    const redisOnline = await presenceStore.isOnline(row.id);
    if (!redisOnline && !row.is_online) continue;
    list.push(buildCustomerDiscoveryCard(row, Number(row.distance_m), redisOnline));
  }

  const sessionId = input.sessionId?.trim();
  if (sessionId && list.length > 0) {
    await recordListImpressions({
      sessionId,
      providerIds: list.map((item) => item.id),
      latitude: input.latitude,
      longitude: input.longitude,
    });
  }

  return {
    list,
    map: {
      center: { latitude: Number(input.latitude), longitude: Number(input.longitude) },
      markers: list.map((item) => ({
        id: item.id,
        providerId: item.providerId,
        name: item.name,
        approximateLocation: item.approximateLocation,
        available: item.availability.isAvailable,
        verified: item.verified,
      })),
    },
    meta: {
      count: list.length,
      radiusKm: radiusM / 1000,
      category: category ? { id: category.id, name: category.name, slug: category.slug } : null,
      geoEngine: engine,
      privacy: {
        approximateOnly: true,
        maskRadiusMeters: env.PRIVACY_MASK_RADIUS_METERS,
        note: "Exact provider coordinates are never exposed to customers",
      },
      customerFlow: {
        maxTapsToContact: 4,
        steps: ["categories", "search", "profile", "call_or_whatsapp"],
      },
      emptyState: buildCustomerEmptyState({
        count: list.length,
        radiusKm: radiusM / 1000,
        category,
      }),
    },
  };
}

/** Backward-compatible list-only nearby (Phase 2). */
export async function findNearbyProvidersForCustomers(input) {
  const result = await searchDiscovery(input);
  return { items: result.list, meta: result.meta };
}

export async function getPublicProviderProfile(publicId, customerLat, customerLng, options = {}) {
  const { rows } = await query(
    `SELECT ${PROVIDER_DISCOVERY_SELECT}, p.phone, s.code AS provider_status
     FROM providers p
     JOIN statuses s ON s.id = p.status_id
     JOIN categories c ON c.id = p.category_id AND c.is_enabled = true
     LEFT JOIN locations l ON l.provider_id = p.id
     ${VERIFICATION_LATERAL}
     WHERE p.public_id = $1`,
    [publicId],
  );
  const row = rows[0];
  if (!row || row.provider_status !== PROVIDER_STATUS.APPROVED) {
    throw new NotFoundError("Provider not found");
  }

  const redisOnline = await presenceStore.isOnline(row.id);
  let distanceM = null;
  if (
    customerLat !== undefined &&
    customerLng !== undefined &&
    row.latitude != null &&
    row.longitude != null
  ) {
    distanceM = distanceMeters(
      Number(customerLat),
      Number(customerLng),
      Number(row.latitude),
      Number(row.longitude),
    );
  }

  const sessionId = options.sessionId?.trim();
  if (sessionId) {
    await recordFunnelEvent({
      providerId: row.id,
      eventType: FUNNEL_EVENT.PROFILE_VIEW,
      sessionId,
      latitude: customerLat ?? null,
      longitude: customerLng ?? null,
    });
  }

  const card = buildCustomerDiscoveryCard(row, distanceM ?? 0, redisOnline);
  return {
    ...card,
    distanceMeters: distanceM === null ? null : Math.round(distanceM),
    city: row.city ?? null,
    contact: buildDirectContactActions(row.phone, customerLat, customerLng),
  };
}

export async function listDiscoveryCategories() {
  const { rows } = await query(
    `SELECT id, name, slug FROM categories WHERE is_enabled = true ORDER BY name`,
  );
  return rows;
}
