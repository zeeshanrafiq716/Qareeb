import { Server } from "socket.io";
import { env } from "../config/env.js";
import { PROVIDER_STATUS, ROLES } from "../config/constants.js";
import { getPool } from "../db/pool.js";
import { logger } from "../logger.js";
import { verifyToken } from "../utils/tokens.js";
import { fetchProviderById } from "../modules/serializers.js";
import * as presence from "../modules/presence.service.js";
import {
  addProviderSocket,
  removeProviderSocket,
} from "./connections.js";

function corsOrigin() {
  if (env.CORS_ORIGIN === "*") return true;
  return env.CORS_ORIGIN.split(",").map((item) => item.trim());
}

function readToken(socket) {
  const auth = socket.handshake.auth?.token;
  if (auth) return String(auth).replace(/^Bearer\s+/i, "");
  const header = socket.handshake.headers?.authorization;
  if (header) return String(header).replace(/^Bearer\s+/i, "");
  return null;
}

export function attachRealtime(httpServer) {
  const io = new Server(httpServer, {
    cors: { origin: corsOrigin() },
    path: "/socket.io",
  });

  io.use(async (socket, next) => {
    try {
      const token = readToken(socket);
      if (!token) throw new Error("Missing token");

      const payload = verifyToken(token);
      if (payload.role !== ROLES.PROVIDER) {
        throw new Error("Provider token required");
      }

      const provider = await fetchProviderById(getPool(), payload.sub);
      if (!provider) throw new Error("Provider not found");
      if (provider.status_code !== PROVIDER_STATUS.APPROVED) {
        throw new Error("Only approved providers can go online");
      }

      socket.data.provider = provider;
      next();
    } catch (error) {
      next(error);
    }
  });

  io.on("connection", async (socket) => {
    const provider = socket.data.provider;
    const providerId = provider.id;

    addProviderSocket(providerId, socket.id);
    await presence.setOnline(providerId);

    const state = await presence.getProviderPresence(providerId);
    socket.emit("presence:state", state);
    io.emit("presence:provider_online", {
      providerId,
      publicId: provider.public_id,
      at: new Date().toISOString(),
    });

    logger.info({ providerId, socketId: socket.id }, "Provider socket connected");

    socket.on("presence:heartbeat", async () => {
      await presence.touchLastSeen(providerId);
      socket.emit("presence:ack", { at: new Date().toISOString() });
    });

    socket.on("disconnect", async (reason) => {
      const remaining = removeProviderSocket(providerId, socket.id);
      if (remaining === 0) {
        await presence.setOffline(providerId);
        io.emit("presence:provider_offline", {
          providerId,
          publicId: provider.public_id,
          reason,
          at: new Date().toISOString(),
        });
      }
      logger.info({ providerId, reason, remaining }, "Provider socket disconnected");
    });
  });

  return io;
}
