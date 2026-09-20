# Phase 2 — Real-time presence

## WebSocket (Socket.io)

- **URL:** same host as API, path `/socket.io`
- **Auth:** provider JWT (approved providers only)

**Quick test (project folder):**

```powershell
cd "D:\projects\Qareeb App"
node scripts/socket-presence-demo.mjs $providerToken
```

```javascript
import { io } from "socket.io-client";

const socket = io("http://localhost:3000", {
  auth: { token: providerJwt },
});

socket.on("connect", () => console.log("connected"));
socket.on("presence:state", (data) => console.log("state", data));

setInterval(() => socket.emit("presence:heartbeat"), 30000);

socket.on("presence:ack", (p) => console.log("heartbeat ack", p));
socket.on("disconnect", (reason) => console.log("disconnect", reason));
```

### Server events (broadcast)

| Event | Meaning |
|--------|---------|
| `presence:provider_online` | Provider came online |
| `presence:provider_offline` | Last socket disconnected |

### Client → server

| Event | Meaning |
|--------|---------|
| `presence:heartbeat` | Refresh `last_seen_at` (every ~30s) |

## REST

```http
GET /api/v1/providers/me/presence
Authorization: Bearer {{providerToken}}

GET /api/v1/admin/providers/online
Authorization: Bearer {{adminToken}}
```

## Stale providers

- `PRESENCE_STALE_SECONDS` (default 90): no heartbeat → marked offline
- Background sweep every `PRESENCE_SWEEP_INTERVAL_MS` (default 60s)

## Phase 1 checklist vs deliverable

| Phase 1 item | Status |
|--------------|--------|
| Backend foundation + DB | Done |
| Provider registration + admin flow | Done |
| Staging | Local/staging script; cloud deploy when you choose host |

Phase 2 presence is **in progress on this branch** — WebSocket + DB fields + admin online list.
