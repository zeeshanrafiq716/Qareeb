# Phase 3 — Customer discovery + provider profile

## Customer flow

1. **Category selection** — `GET /api/v1/discovery/categories`
2. **Customer location** — pass `latitude` + `longitude` on search (customer position is echoed as map center only)
3. **Search** — `GET /api/v1/discovery/search?latitude=&longitude=&categoryId=&categorySlug=&radiusKm=5`

## Response shape

```json
{
  "success": true,
  "data": {
    "list": [ { "name", "photoUrl", "distanceMeters", "rating", "verified", "availability", "approximateLocation" } ],
    "map": { "center": { "latitude", "longitude" }, "markers": [ ... ] }
  },
  "meta": { "geoEngine": "postgis|haversine", "category", "count", "privacy": { ... } }
}
```

## Provider profile (customer)

```http
GET /api/v1/discovery/providers/QRB-100001?latitude=31.52&longitude=74.35
```

Returns: name, photo, distance, rating, verified badge, availability, and **direct contact** actions (`tel:`, `wa.me`, optional share-location via WhatsApp). **No exact GPS** on the map pin; phone is only on the profile, not in search list.

## Direct contact (not hosted by Qareeb)

- **Call** — `contact.actions.call.url` → native dialer (`tel:+92…`)
- **WhatsApp** — `contact.actions.whatsapp.url` → WhatsApp app
- **Share location** — `contact.actions.shareLocation.whatsappUrl` when customer lat/lng is on the profile request

Pass anonymous funnel id via header `X-Customer-Session` or query `sessionId` (8–64 chars).

## Accountability / funnel

| Event | When |
|-------|------|
| `list_impression` | Auto when search returns providers (with session) |
| `profile_view` | Auto on profile GET (with session) |
| `profile_click`, `call_click`, `whatsapp_click`, `share_location_click` | `POST /api/v1/discovery/events` when user taps |

Admin: `GET /api/v1/admin/providers/:id/funnel?days=30`

`call_click` also appends a row to `call_logs` (intent only — Qareeb does not host the call).

## End-to-end customer flow (≤4 taps)

1. Categories → 2. Search (list/map) → 3. Provider profile (includes contact URLs) → 4. Call or WhatsApp

## Privacy

- Provider pins use **~300m approximate** locations only
- Only **approved + online + fresh location** providers in results
- **Customers never appear** on provider-side maps (no customer location APIs for providers)

## Legacy

`GET /api/v1/discovery/nearby` — list-only (Phase 2 compatible)
