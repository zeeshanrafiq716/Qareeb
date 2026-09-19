import { ZodError } from "zod";
import { env } from "../config/env.js";
import { logger } from "../logger.js";
import { AppError } from "../utils/AppError.js";

export function notFoundHandler(req, res, _next) {
  res.status(404).json({
    success: false,
    error: {
      code: "NOT_FOUND",
      message: `Route not found: ${req.method} ${req.path}`,
    },
  });
}

export function errorHandler(err, req, res, _next) {
  if (err instanceof ZodError) {
    return res.status(400).json({
      success: false,
      error: {
        code: "VALIDATION_ERROR",
        message: "Invalid request data",
        details: err.issues.map((issue) => ({
          path: issue.path.join("."),
          message: issue.message,
        })),
      },
    });
  }

  if (err instanceof AppError) {
    if (err.statusCode >= 500) {
      logger.error({ err, reqId: req.id }, err.message);
    }
    return res.status(err.statusCode).json({
      success: false,
      error: {
        code: err.code,
        message: err.message,
        details: err.details,
      },
    });
  }

  if (err.code === "23505") {
    return res.status(409).json({
      success: false,
      error: { code: "DUPLICATE", message: "Record already exists" },
    });
  }

  if (err.code === "23503") {
    return res.status(400).json({
      success: false,
      error: { code: "INVALID_REFERENCE", message: "Related record does not exist" },
    });
  }

  if (err.code === "LIMIT_FILE_SIZE") {
    return res.status(400).json({
      success: false,
      error: { code: "FILE_TOO_LARGE", message: "Uploaded file is too large" },
    });
  }

  logger.error({ err, url: req.originalUrl }, "Unhandled error");

  return res.status(500).json({
    success: false,
    error: {
      code: "INTERNAL_ERROR",
      message: env.isProd ? "Something went wrong" : err.message,
    },
  });
}
