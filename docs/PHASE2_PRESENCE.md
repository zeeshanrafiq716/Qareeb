# Phase 2 — Complete (presence + location + geo + privacy)

## Features

| Area | Implementation |
|------|----------------|
| WebSocket | Socket.io `/socket.io` — online/offline, reconnect, multi-tab sessions |
| Redis | Online state, sessions, recent location (fallback: in-memory if Redis down) |
| Location | Min **30s** interval OR **75m** significant movement; max freshness **60s** for discovery |
| PostGIS | Optional (`optional_004_postgis.sql`); fallback haversine in PostgreSQL |
| Privacy | Customer API returns **~300m approximate** point + distance only |
| Discovery | `GET /api/v1/discovery/nearby` — approved, online, fresh location only |

## Environment

```env
REDIS_URL=redis://127.0.0.1:6379
REDIS_ENABLED=true   # set false if Redis is not running (in-memory fallback)
LOCATION_MIN_INTERVAL_SECONDS=30
LOCATION_MAX_INTERVAL_SECONDS=60
LOCATION_SIGNIFICANT_MOVEMENT_METERS=75
PRIVACY_MASK_RADIUS_METERS=300
PRESENCE_STALE_SECONDS=90
```

Start Redis (optional Docker):

```bash
docker compose up -d redis
```

## WebSocket events (provider — approved only)

| Client → Server | Server → Client |
|-----------------|-----------------|
| `presence:heartbeat` | `presence:ack` |
| `presence:location_update` `{ latitude, longitude }` | `presence:location_ack` |
| connect | `presence:state` |

Broadcast: `presence:provider_online`, `presence:provider_offline`, `presence:provider_location`

## REST

```http
GET  /api/v1/providers/me/presence
PUT  /api/v1/providers/me/location
GET  /api/v1/admin/providers/online
GET  /api/v1/discovery/nearby?latitude=&longitude=&radiusKm=5
```

## Manual socket test

```powershell
cd "D:\projects\Qareeb App"
node scripts/socket-presence-demo.mjs $providerToken
```

## Phase 2 deliverable checklist

- [x] Live online/offline via Socket.io
- [x] Redis presence layer (+ memory fallback)
- [x] Battery-friendly location throttling
- [x] Geospatial nearby query (PostGIS or haversine)
- [x] Privacy: no exact coords to customers
- [x] Automated tests (`npm test` — 44 tests)

## Phase 3 preview

Customer discovery UI, direct contact, ratings — builds on `/discovery/nearby`.
