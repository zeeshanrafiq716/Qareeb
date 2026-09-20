import { env } from "../config/env.js";
import { AppError } from "../utils/AppError.js";
import { incrementRateLimit } from "../redis/rateLimitStore.js";

function clientIp(req) {
  const forwarded = req.headers["x-forwarded-for"];
  if (typeof forwarded === "string" && forwarded.length > 0) {
    return forwarded.split(",")[0].trim();
  }
  return req.ip || req.socket?.remoteAddress || "unknown";
}

/**
 * @param {{ windowSeconds: number, limit: number, keyPrefix: string, keyGenerator?: (req) => string }} options
 */
export function rateLimit(options) {
  const { windowSeconds, limit, keyPrefix, keyGenerator } = options;
  return async (req, res, next) => {
    if (!env.RATE_LIMIT_ENABLED || env.isTest) {
      return next();
    }
    try {
      const suffix = keyGenerator ? keyGenerator(req) : clientIp(req);
      const key = `qareeb:rl:${keyPrefix}:${suffix}`;
      const result = await incrementRateLimit(key, windowSeconds, limit);
      res.setHeader("X-RateLimit-Limit", String(limit));
      res.setHeader("X-RateLimit-Remaining", String(result.remaining));
      if (!result.allowed) {
        res.setHeader("Retry-After", String(result.retryAfterSeconds));
        throw new AppError(
          429,
          "Too many requests. Please try again later.",
          "RATE_LIMITED",
          { retryAfterSeconds: result.retryAfterSeconds },
        );
      }
      return next();
    } catch (error) {
      if (error instanceof AppError) throw error;
      return next();
    }
  };
}

export function otpRequestRateLimit() {
  return rateLimit({
    windowSeconds: env.OTP_RATE_LIMIT_WINDOW_SECONDS,
    limit: env.OTP_RATE_LIMIT_PER_IP,
    keyPrefix: "otp-ip",
    keyGenerator: (req) => clientIp(req),
  });
}

export function otpVerifyRateLimit() {
  return rateLimit({
    windowSeconds: 60,
    limit: env.OTP_VERIFY_RATE_LIMIT_PER_IP,
    keyPrefix: "otp-verify-ip",
    keyGenerator: (req) => clientIp(req),
  });
}

export function adminLoginRateLimit() {
  return rateLimit({
    windowSeconds: 900,
    limit: env.ADMIN_LOGIN_RATE_LIMIT,
    keyPrefix: "admin-login",
    keyGenerator: (req) => clientIp(req),
  });
}

export function apiGlobalRateLimit() {
  return rateLimit({
    windowSeconds: 60,
    limit: env.API_RATE_LIMIT_PER_MINUTE,
    keyPrefix: "api",
    keyGenerator: (req) => clientIp(req),
  });
}
