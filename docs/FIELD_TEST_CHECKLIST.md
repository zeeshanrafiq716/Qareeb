# Qareeb — Release test checklist (required before “done”)

Use this for **provider app**, **customer app**, and **backend** together. Mark each row Pass/Fail with date, device, and tester.

---

## 1. Battery test (8-hour provider day)

**Goal:** Provider stays “online” a full workday without unacceptable drain.

| # | Step | Pass criteria |
|---|------|----------------|
| 1.1 | Fully charge test phone; note % at start | Baseline recorded |
| 1.2 | Provider app online 8h (typical brightness, real SIM) | App not killed by OS battery saver |
| 1.3 | Location updates follow policy (≥30s interval, movement threshold) | Network calls not continuous; check server logs or proxy |
| 1.4 | End battery % vs control day (app installed but offline) | **≤15% extra drain** vs control, or within team target |
| 1.5 | Socket reconnects after short screen-off periods | Presence returns without manual restart |

**Backend:** `LOCATION_MIN_INTERVAL_SECONDS`, `LOCATION_SIGNIFICANT_MOVEMENT_METERS` documented in `.env`.

---

## 2. Real road / field test (live movement)

| # | Step | Pass criteria |
|---|------|----------------|
| 2.1 | Approved provider drives/walks 2–5 km with app foreground/background mix | Location updates accepted (not all 429 throttled) |
| 2.2 | Admin map `GET /admin/providers/map` | Marker moves; `mapStatus` reflects online + fresh location |
| 2.3 | Customer search near route | Provider appears when online + fresh; distance plausible |
| 2.4 | Stop 5 min | Stale location policy: may drop from customer search — expected |

---

## 3. Poor-network test

| # | Step | Pass criteria |
|---|------|----------------|
| 3.1 | Throttle to 3G/EDGE or use network link conditioner | No hard crash |
| 3.2 | OTP request / verify on slow link | Timeouts show retry message; no duplicate providers |
| 3.3 | Discovery search with 5–10s latency | Loading state; no frozen map |
| 3.4 | Socket disconnect | Auto-reconnect; presence recovers |
| 3.5 | Airplane mode 30s then on | App recovers without reinstall |

---

## 4. Location accuracy check

| # | Step | Pass criteria |
|---|------|----------------|
| 4.1 | Stand at known landmark; note GPS | Provider lat/lng within **~50m** of ground truth (open sky) |
| 4.2 | Customer search from same area | Distance on profile matches walk estimate |
| 4.3 | Customer map pins | **Approximate** only (~300m); never exact provider home |
| 4.4 | Share-location WhatsApp link | Customer position in message matches map |

---

## 5. Empty-map screen (no providers online)

| # | Step | Pass criteria |
|---|------|----------------|
| 5.1 | Customer search when no approved+online+fresh providers | HTTP 200, `list: []`, `meta.emptyState` present |
| 5.2 | UI shows empty state copy (EN) | Title + hints + widen radius / change category |
| 5.3 | Map center still customer location | No crash on zero markers |
| 5.4 | Retry after provider goes online | List populates without app restart |

**API sample:** `GET /api/v1/discovery/search?latitude=…&longitude=…` → `meta.emptyState.screen === "empty_map"`.

---

## 6. Arabic RTL — every screen

Apply to **provider** and **customer** apps.

| Area | Check |
|------|--------|
| Navigation | Back chevrons, tab order mirror in RTL |
| Discovery | Category chips, list cards, distance text aligned right |
| Profile | Name, badges, Call/WhatsApp buttons |
| Empty map | Use `meta.emptyState.title.ar` / `message.ar` |
| Forms | Phone, OTP, profile — digits LTR inside RTL layout |
| Admin (if localized) | Tables and map legend |

**Pass:** No clipped text, no overlapping icons, logical reading order in `ar` locale on **all** screens in the test matrix below.

### Screen matrix (sign off each)

- [ ] Splash / login  
- [ ] OTP entry  
- [ ] Provider home / online toggle  
- [ ] Customer categories  
- [ ] Customer list + map  
- [ ] Provider public profile + contact actions  
- [ ] Empty map  
- [ ] Settings / logout  

---

## 7. Backend / infra smoke (automated)

```bash
npm test
curl http://127.0.0.1:3000/health/ready
```

- [ ] Migration `007_infrastructure.sql` applied  
- [ ] `OTP_RETURN_IN_RESPONSE=false` on production  
- [ ] Redis enabled in staging/production  
- [ ] Backup script run once; restore verified  
- [ ] FCM token register + admin send (staging with `FCM_ENABLED=true`)  

---

## Sign-off

| Role | Name | Date | Build/version |
|------|------|------|----------------|
| QA | | | |
| Product | | | |
| Backend | | | |
| Mobile | | | |

**Release is not “done” until all sections 1–6 have documented Pass results on real devices.**
