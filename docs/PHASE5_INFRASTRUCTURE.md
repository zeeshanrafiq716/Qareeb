# Phase 5 — Infrastructure

## Security & rate limiting

| Layer | Behavior |
|-------|----------|
| **Helmet** | Default security headers |
| **Global API** | `120 req/min/IP` (`API_RATE_LIMIT_PER_MINUTE`) — disabled in `NODE_ENV=test` |
| **OTP request** | IP limit + per-phone limit + **60s cooldown** between SMS requests |
| **OTP verify** | 30 attempts/min/IP |
| **Admin login** | 10 attempts / 15 min / IP |
| **Production guard** | `NODE_ENV=production` refuses weak JWT, OTP in response, static OTP, default admin password, `CORS=*` |

Env: `RATE_LIMIT_ENABLED`, `OTP_*`, `ADMIN_LOGIN_RATE_LIMIT`.

## OTP protection

- Hashed OTP in DB, max attempts, expiry (Phase 1)
- **Audit table** `otp_request_audit` (phone, IP, user agent)
- Per-phone hourly cap: `OTP_RATE_LIMIT_PER_PHONE`

## FCM push notifications

Provider registers token:

```http
PUT /api/v1/providers/me/push-token
Authorization: Bearer <provider JWT>
{ "token": "...", "platform": "android", "appVersion": "1.0.0" }
```

Admin send (when configured):

```http
POST /api/v1/admin/notifications/send
{ "providerId": "<uuid>", "title": "...", "body": "..." }
```

Env:

- `FCM_ENABLED=true`
- `FCM_PROJECT_ID`
- `FCM_SERVICE_ACCOUNT_JSON` — full Firebase service account JSON (one line in `.env` or secret manager)

Dev/staging: leave `FCM_ENABLED=false` — API stores tokens and logs mock sends.

## Monitoring & readiness

- `GET /health` — liveness
- `GET /health/ready` — Postgres + Redis checks, PostGIS flag
- `X-Request-Id` on every response
- Optional `MONITORING_WEBHOOK_URL` for unhandled 5xx (Slack/Discord/custom)

## Database / Redis / PostGIS

- Migration `007_infrastructure.sql` — device tokens, OTP audit, indexes
- **PostGIS** (optional): run `migrations/optional_004_postgis.sql` on Postgres with PostGIS extension for faster discovery
- **Redis**: recommended in production for presence + rate limits (`REDIS_ENABLED=true`)

## Backups

```powershell
.\scripts\backup-postgres.ps1
```

Schedule daily on the DB host; test restore monthly.

## Field & release testing

**Required before “done”** — see [`FIELD_TEST_CHECKLIST.md`](./FIELD_TEST_CHECKLIST.md) (battery, road test, poor network, location accuracy, empty map, Arabic RTL).
