import { Router } from "express";
import { asyncHandler } from "../../utils/asyncHandler.js";
import { created, ok } from "../../utils/http.js";
import { validate } from "../../middleware/validate.js";
import { requireProvider } from "../../middleware/auth.js";
import { publicFileUrl, upload } from "../../middleware/upload.js";
import { profileSchema, verificationSchema } from "../schemas.js";
import * as authService from "../auth.service.js";
import * as providerService from "../providers.service.js";

export const providerRoutes = Router();

providerRoutes.get(
  "/me",
  requireProvider,
  asyncHandler(async (req, res) => {
    ok(res, await authService.getMe(req.provider.id));
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
    created(
      res,
      await providerService.submitVerification(req.provider, {
        documentType: req.body.documentType,
        documentUrl: publicFileUrl(req.file),
      }),
    );
  }),
);
