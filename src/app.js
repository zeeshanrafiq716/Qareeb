import path from "node:path";
import express from "express";
import cors from "cors";
import helmet from "helmet";
import pinoHttp from "pino-http";
import { env } from "./config/env.js";
import { logger } from "./logger.js";
import { apiRouter } from "./modules/routes/index.js";
import { asyncHandler } from "./utils/asyncHandler.js";
import { errorHandler, notFoundHandler } from "./middleware/errorHandler.js";
import { requestIdMiddleware } from "./middleware/requestId.js";
import { apiGlobalRateLimit } from "./middleware/rateLimit.js";
import { getReadinessCheck } from "./monitoring/health.service.js";

export function createApp() {
  const app = express();

  app.disable("x-powered-by");
  app.set("trust proxy", 1);
  app.use(requestIdMiddleware);
  app.use(
    helmet({
      crossOriginResourcePolicy: { policy: "cross-origin" },
    }),
  );
  app.use(
    cors({
      origin: env.CORS_ORIGIN === "*" ? true : env.CORS_ORIGIN.split(",").map((item) => item.trim()),
    }),
  );
  app.use(express.json({ limit: "1mb" }));
  app.use(express.urlencoded({ extended: true }));
  app.use(
    pinoHttp({
      logger,
      autoLogging: !env.isTest,
    }),
  );

  app.use("/uploads", express.static(path.resolve(process.cwd(), env.UPLOAD_DIR)));

  app.get("/", (_req, res) => {
    res.json({
      success: true,
      data: {
        name: "Qareeb App",
        phase: 5,
        message: "Discovery, admin, infrastructure (FCM, rate limits, monitoring)",
      },
    });
  });

  app.get("/health", (_req, res) => {
    res.json({ success: true, data: { status: "healthy", phase: 5 } });
  });

  app.get(
    "/health/ready",
    asyncHandler(async (_req, res) => {
      const readiness = await getReadinessCheck();
      res.status(readiness.healthy ? 200 : 503).json({ success: readiness.healthy, data: readiness });
    }),
  );

  app.use("/api/v1", apiGlobalRateLimit(), apiRouter);
  app.use(notFoundHandler);
  app.use(errorHandler);
  return app;
}
