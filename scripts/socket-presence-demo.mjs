/**
 * Manual Phase 2 WebSocket test (approved provider JWT required).
 *
 * Usage:
 *   node scripts/socket-presence-demo.mjs YOUR_PROVIDER_JWT
 */
import { io } from "socket.io-client";

const token = process.argv[2];
if (!token) {
  console.error("Usage: node scripts/socket-presence-demo.mjs <providerJwt>");
  process.exit(1);
}

const base = process.env.API_BASE || "http://127.0.0.1:3000";
const socket = io(base, { auth: { token } });

const demoLat = 31.5204;
const demoLng = 74.3587;

socket.on("connect", () => {
  console.log("connected", socket.id);
  socket.emit("presence:heartbeat");
  socket.emit("presence:location_update", { latitude: demoLat, longitude: demoLng }, (ack) => {
    console.log("location ack", ack);
  });
});

socket.on("connect_error", (err) => {
  console.error("connect_error:", err.message);
  process.exit(1);
});

socket.on("presence:state", (data) => {
  console.log("presence:state", JSON.stringify(data?.presence ?? data, null, 2));
});

socket.on("presence:ack", (payload) => {
  console.log("presence:ack", payload);
});

socket.on("presence:location_ack", (payload) => {
  console.log("presence:location_ack", payload);
});

setTimeout(() => {
  console.log("disconnecting...");
  socket.disconnect();
  process.exit(0);
}, 5000);
