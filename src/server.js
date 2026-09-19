import { env } from "./config/env.js";
import { createApp } from "./app.js";
import { logger } from "./logger.js";
import { closePool } from "./db/pool.js";
import { setupDatabase } from "./db/setup.js";

export async function startServer() {
  if (env.AUTO_MIGRATE) {
    await setupDatabase(env.DATABASE_URL);
  }

  const app = createApp();
  const server = app.listen(env.PORT, "0.0.0.0", () => {
    logger.info(`Qareeb App Phase 1 running on http://localhost:${env.PORT}`);
  });

  server.on("error", (error) => {
    logger.error({ err: error }, "HTTP server failed");
    process.exit(1);
  });

  const shutdown = async (signal) => {
    logger.info({ signal }, "Shutting down");
    server.close(async () => {
      await closePool();
      process.exit(0);
    });
  };

  process.on("SIGINT", () => shutdown("SIGINT"));
  process.on("SIGTERM", () => shutdown("SIGTERM"));
  return server;
}
