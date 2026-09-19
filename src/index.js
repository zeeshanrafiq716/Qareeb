import { startServer } from "./server.js";
import { logger } from "./logger.js";

startServer().catch((error) => {
  logger.error({ err: error }, "Failed to start server");
  process.exit(1);
});
