# Phase 4 — Admin panel APIs + production deployment

Backend APIs for an admin dashboard (web or mobile). All routes under `/api/v1/admin/*` require `Authorization: Bearer <admin JWT>` except login.

## Authentication

```http
POST /api/v1/admin/auth/login
{ "email": "admin@qareeb.app", "password": "..." }
```

## Provider operations

| Action | Method | Path |
|--------|--------|------|
| List / filter | GET | `/admin/providers?status=&search=&page=&limit=` |
| Lookup by **QRB id** or **phone** | GET | `/admin/providers/lookup?q=QRB-100001` or `?q=03001234567` |
| Details + history + call logs | GET | `/admin/providers/:uuid` |
| Approve / reject / suspend / reinstate | POST | `/admin/providers/:uuid/{approve\|reject\|suspend\|reinstate}` |
| Per-provider funnel | GET | `/admin/providers/:uuid/funnel?days=30` |
| Per-provider call logs | GET | `/admin/providers/:uuid/call-logs` |

`search` on the list uses **exact** match for `QRB-…` and normalized E.164 phone; otherwise name/phone partial match.

## Live provider map (admin only)

```http
GET /api/v1/admin/providers/map?status=approved&categoryId=
```

Returns **exact** GPS (not customer-facing approximate pins).

Each marker includes:

- `mapStatus`: `online` | `offline` | `suspended` | `inactive` (pending/rejected)
- `accountStatus`: provider workflow status
- `presence`, `location`

Response includes `summary` counts for map legend.

## Categories

Same as Phase 1: `GET/POST/PATCH/DELETE /admin/categories`.

## Call logs & funnel analytics

```http
GET /api/v1/admin/call-logs?page=1&limit=20&providerId=
GET /api/v1/admin/analytics/funnel?days=30
```

Platform funnel totals + top providers by profile views / call clicks.

## Production deployment (Docker)

1. Copy env: `cp .env.staging.example .env.staging` and set secrets (`JWT_SECRET`, `ADMIN_PASSWORD`, `DATABASE_URL`, `CORS_ORIGIN`).
2. Start stack:

```bash
docker compose up -d postgres redis
docker compose up -d --build api
```

3. Smoke test:

```bash
npm run test:staging   # server must be on :3000
```

4. Health: `GET /health` and `GET /api/v1/health` → `phase: 4`.

### Checklist before go-live

- [ ] `OTP_RETURN_IN_RESPONSE=false` (no OTP in API body)
- [ ] Strong `JWT_SECRET` and admin password
- [ ] Postgres + Redis persisted volumes
- [ ] HTTPS reverse proxy (nginx/Caddy) in front of port 3000
- [ ] Backups for Postgres volume `qareeb_pg`
- [ ] `CORS_ORIGIN` restricted to admin/app domains

## Testing

```bash
npm test
```

Phase 4 coverage: `tests/admin-phase4.test.js`, existing `tests/admin.test.js`.

Manual PowerShell: **PHASE 4** block in `docs/test-file`.
