import { Router } from "express";
import { asyncHandler } from "../../utils/asyncHandler.js";
import { created, ok } from "../../utils/http.js";
import { validate } from "../../middleware/validate.js";
import { optionalProvider, requireProvider } from "../../middleware/auth.js";
import { publicFileUrl, upload } from "../../middleware/upload.js";
import { kycTokenSchema, profileSchema, verificationSchema } from "../schemas.js";
import * as authService from "../auth.service.js";
import * as providerService from "../providers.service.js";
import { getProviderPresence } from "../presence.service.js";
import { processLocationUpdate } from "../location.service.js";
import {
  getProviderDashboardAnalytics,
  getProviderQuickStats,
} from "../funnel.service.js";
import { deviceTokenSchema, locationUpdateSchema } from "../schemas.js";
import {
  registerProviderDeviceToken,
  removeProviderDeviceToken,
} from "../notifications.service.js";
import {
  checkDocumentExpiry,
  generateKycAccessToken,
  inspectDocumentImage,
  processKycWebhook,
} from "../kyc.service.js";

export const providerRoutes = Router();

providerRoutes.get(
  "/me",
  requireProvider,
  asyncHandler(async (req, res) => {
    ok(res, await authService.getMe(req.provider.id));
  }),
);

providerRoutes.get(
  "/me/stats",
  optionalProvider,
  asyncHandler(async (req, res) => {
    const providerId = req.provider?.id || req.query.providerId || null;
    const stats = await getProviderQuickStats(providerId);
    ok(res, stats);
  }),
);

providerRoutes.get(
  "/me/dashboard",
  optionalProvider,
  asyncHandler(async (req, res) => {
    const providerId = req.provider?.id || req.query.providerId || null;
    const dashboard = await getProviderDashboardAnalytics(providerId);
    ok(res, dashboard);
  }),
);

providerRoutes.get(
  "/me/presence",
  requireProvider,
  asyncHandler(async (req, res) => {
    ok(res, await getProviderPresence(req.provider.id));
  }),
);

providerRoutes.put(
  "/me/location",
  requireProvider,
  validate(locationUpdateSchema),
  asyncHandler(async (req, res) => {
    ok(res, await processLocationUpdate(req.provider.id, req.body.latitude, req.body.longitude));
  }),
);

providerRoutes.put(
  "/me/push-token",
  requireProvider,
  validate(deviceTokenSchema),
  asyncHandler(async (req, res) => {
    ok(res, await registerProviderDeviceToken(req.provider.id, req.body));
  }),
);

providerRoutes.delete(
  "/me/push-token",
  requireProvider,
  validate(deviceTokenSchema),
  asyncHandler(async (req, res) => {
    ok(res, await removeProviderDeviceToken(req.provider.id, req.body.token));
  }),
);

providerRoutes.put(
  "/me/profile",
  requireProvider,
  upload.single("photo"),
  validate(profileSchema),
  asyncHandler(async (req, res) => {
    ok(
      res,
      await providerService.updateProfile(req.provider, {
        ...req.body,
        photoUrl: publicFileUrl(req.file),
      }),
    );
  }),
);

providerRoutes.post(
  "/me/verification",
  requireProvider,
  upload.single("document"),
  validate(verificationSchema),
  asyncHandler(async (req, res) => {
    // 1. Inspect image clarity, dummy/blank check, and size
    const qualityReport = await inspectDocumentImage(req.file);

    // 2. Validate expiry date if provided
    const expiryReport = checkDocumentExpiry(req.body.expiryDate);

    // 3. Record verification in database
    const verificationResult = await providerService.submitVerification(req.provider, {
      documentType: req.body.documentType,
      documentUrl: publicFileUrl(req.file),
    });

    created(res, {
      ...verificationResult,
      qualityReport,
      expiryReport,
    });
  }),
);

providerRoutes.post(
  "/me/kyc/token",
  requireProvider,
  validate(kycTokenSchema),
  asyncHandler(async (req, res) => {
    const tokenResult = await generateKycAccessToken({
      providerId: req.provider.id,
      levelName: req.body.levelName,
    });
    ok(res, tokenResult);
  }),
);

providerRoutes.post(
  "/kyc/webhook",
  asyncHandler(async (req, res) => {
    const signature = req.headers["x-payload-digest"];
    const timestamp = req.headers["x-payload-timestamp"];
    const result = await processKycWebhook({
      payload: req.body,
      signature,
      timestamp,
    });
    ok(res, result);
  }),
);
