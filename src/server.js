import http from "node:http";
import { env } from "./config/env.js";
import { createApp } from "./app.js";
import { logger } from "./logger.js";
import { closePool } from "./db/pool.js";
import { setupDatabase } from "./db/setup.js";
import { attachRealtime } from "./realtime/socket.js";
import { sweepStaleProviders } from "./modules/presence.service.js";

export async function startServer() {
  if (env.AUTO_MIGRATE) {
    await setupDatabase(env.DATABASE_URL);
  }

  const app = createApp();
  const httpServer = http.createServer(app);
  attachRealtime(httpServer);

  let staleTimer;
  if (!env.isTest) {
    staleTimer = setInterval(async () => {
      try {
        const count = await sweepStaleProviders();
        if (count > 0) {
          logger.info({ count }, "Marked stale providers offline");
        }
      } catch (error) {
        logger.error({ err: error }, "Presence sweep failed");
      }
    }, env.PRESENCE_SWEEP_INTERVAL_MS);
  }

  httpServer.listen(env.PORT, "0.0.0.0", () => {
    logger.info(
      `Qareeb API (Phase 1 + presence) on http://localhost:${env.PORT} | WebSocket /socket.io`,
    );
  });

  httpServer.on("error", (error) => {
    logger.error({ err: error }, "HTTP server failed");
    process.exit(1);
  });

  const shutdown = async (signal) => {
    logger.info({ signal }, "Shutting down");
    if (staleTimer) clearInterval(staleTimer);
    httpServer.close(async () => {
      await closePool();
      process.exit(0);
    });
  };

  process.on("SIGINT", () => shutdown("SIGINT"));
  process.on("SIGTERM", () => shutdown("SIGTERM"));
  return httpServer;
}
