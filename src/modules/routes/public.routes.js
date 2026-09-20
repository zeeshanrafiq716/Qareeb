import { Router } from "express";
import { asyncHandler } from "../../utils/asyncHandler.js";
import { ok } from "../../utils/http.js";
import { validate } from "../../middleware/validate.js";
import { otpRequestSchema, otpVerifySchema } from "../schemas.js";
import * as authService from "../auth.service.js";
import { otpRequestRateLimit, otpVerifyRateLimit } from "../../middleware/rateLimit.js";
import * as providerService from "../providers.service.js";
import { serializeCategory } from "../serializers.js";

export const publicRoutes = Router();

publicRoutes.get("/health", (_req, res) => {
  ok(res, { status: "healthy", phase: 5 });
});

publicRoutes.get(
  "/categories",
  asyncHandler(async (_req, res) => {
    const rows = await providerService.listEnabledCategories();
    ok(res, rows.map(serializeCategory));
  }),
);

publicRoutes.post(
  "/auth/otp/request",
  otpRequestRateLimit(),
  validate(otpRequestSchema),
  asyncHandler(async (req, res) => {
    ok(
      res,
      await authService.requestOtp(req.body.phone, {
        ipAddress: req.ip,
        userAgent: req.headers["user-agent"],
      }),
    );
  }),
);

publicRoutes.post(
  "/auth/otp/verify",
  otpVerifyRateLimit(),
  validate(otpVerifySchema),
  asyncHandler(async (req, res) => {
    ok(res, await authService.verifyOtp(req.body.phone, req.body.otp));
  }),
);
