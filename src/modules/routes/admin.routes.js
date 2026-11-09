import { Router } from "express";
import { asyncHandler } from "../../utils/asyncHandler.js";
import { created, ok } from "../../utils/http.js";
import { validate, validatedQuery } from "../../middleware/validate.js";
import { requireAdmin } from "../../middleware/auth.js";
import {
  adminAnalyticsSchema,
  adminCallLogsSchema,
  adminLoginSchema,
  adminLookupSchema,
  adminMapSchema,
  adminProfileUpdateSchema,
  categoryCreateSchema,
  categoryPatchSchema,
  categoryReorderSchema,
  idParamSchema,
  optionalReasonSchema,
  providerListSchema,
  reasonSchema,
  vehicleTypeCreateSchema,
  vehicleTypePatchSchema,
  cityCreateSchema,
  cityPatchSchema,
} from "../schemas.js";
import * as adminService from "../admin.service.js";
import { listOnlineProviders } from "../presence.service.js";
import { getPlatformFunnelAnalytics, getProviderFunnelSummary } from "../funnel.service.js";
import { adminLoginRateLimit } from "../../middleware/rateLimit.js";
import { adminPushSchema } from "../schemas.js";
import { sendAdminPush } from "../notifications.service.js";
import { autoTranslateToArabic } from "../../utils/translator.js";

export const adminRoutes = Router();

adminRoutes.post(
  "/auth/login",
  adminLoginRateLimit(),
  validate(adminLoginSchema),
  asyncHandler(async (req, res) => {
    ok(res, await adminService.adminLogin(req.body.email, req.body.password));
  }),
);

adminRoutes.get(
  "/profile",
  requireAdmin,
  asyncHandler(async (req, res) => {
    ok(res, await adminService.getAdminProfile(req.admin.id));
  }),
);

adminRoutes.patch(
  "/profile",
  requireAdmin,
  validate(adminProfileUpdateSchema),
  asyncHandler(async (req, res) => {
    ok(res, await adminService.updateAdminProfile(req.admin.id, req.body));
  }),
);

adminRoutes.post(
  "/notifications/send",
  requireAdmin,
  validate(adminPushSchema),
  asyncHandler(async (req, res) => {
    ok(res, await sendAdminPush(req.body));
  }),
);

adminRoutes.get(
  "/notifications",
  requireAdmin,
  asyncHandler(async (req, res) => {
    ok(res, await adminService.getAdminNotifications());
  }),
);

adminRoutes.get(
  "/providers",
  requireAdmin,
  validate(providerListSchema),
  asyncHandler(async (req, res) => {
    const result = await adminService.listProviders(validatedQuery(req));
    ok(res, result.items, 200, result.meta);
  }),
);

adminRoutes.get(
  "/providers/online",
  requireAdmin,
  validate(providerListSchema),
  asyncHandler(async (req, res) => {
    const result = await listOnlineProviders(validatedQuery(req));
    ok(res, result.items, 200, result.meta);
  }),
);

adminRoutes.get(
  "/providers/lookup",
  requireAdmin,
  validate(adminLookupSchema),
  asyncHandler(async (req, res) => {
    ok(res, await adminService.lookupProvider(validatedQuery(req).q));
  }),
);

adminRoutes.get(
  "/providers/map",
  requireAdmin,
  validate(adminMapSchema),
  asyncHandler(async (req, res) => {
    ok(res, await adminService.listProvidersForAdminMap(validatedQuery(req)));
  }),
);

adminRoutes.get(
  "/providers/:id",
  requireAdmin,
  validate(idParamSchema),
  asyncHandler(async (req, res) => {
    ok(res, await adminService.getProviderDetails(req.params.id));
  }),
);

adminRoutes.post(
  "/providers/:id/approve",
  requireAdmin,
  validate(optionalReasonSchema),
  asyncHandler(async (req, res) => {
    ok(res, await adminService.approveProvider(req.params.id, req.admin, req.body?.reason));
  }),
);

adminRoutes.post(
  "/providers/:id/reject",
  requireAdmin,
  validate(reasonSchema),
  asyncHandler(async (req, res) => {
    ok(res, await adminService.rejectProvider(req.params.id, req.admin, req.body.reason));
  }),
);

adminRoutes.post(
  "/providers/:id/suspend",
  requireAdmin,
  validate(optionalReasonSchema),
  asyncHandler(async (req, res) => {
    ok(res, await adminService.suspendProvider(req.params.id, req.admin, req.body?.reason));
  }),
);

adminRoutes.post(
  "/providers/:id/block",
  requireAdmin,
  validate(optionalReasonSchema),
  asyncHandler(async (req, res) => {
    ok(res, await adminService.blockProvider(req.params.id, req.admin, req.body?.reason));
  }),
);

adminRoutes.post(
  "/providers/:id/reinstate",
  requireAdmin,
  validate(optionalReasonSchema),
  asyncHandler(async (req, res) => {
    ok(res, await adminService.reinstateProvider(req.params.id, req.admin, req.body?.reason));
  }),
);

adminRoutes.delete(
  "/providers/:id",
  requireAdmin,
  validate(idParamSchema),
  asyncHandler(async (req, res) => {
    ok(res, await adminService.deleteProvider(req.params.id, req.admin));
  }),
);

adminRoutes.get(
  "/providers/:id/funnel",
  requireAdmin,
  validate(idParamSchema),
  asyncHandler(async (req, res) => {
    const days = Number(req.query.days) || 30;
    ok(res, await getProviderFunnelSummary(req.params.id, { days }));
  }),
);

adminRoutes.get(
  "/providers/:id/call-logs",
  requireAdmin,
  validate(idParamSchema),
  asyncHandler(async (req, res) => {
    ok(res, await adminService.listCallLogs(req.params.id));
  }),
);

adminRoutes.post(
  "/providers/:id/call-logs",
  requireAdmin,
  validate(idParamSchema),
  asyncHandler(async (req, res) => {
    created(res, await adminService.createCallLog(req.params.id, req.body || {}));
  }),
);

adminRoutes.get(
  "/analytics/funnel",
  requireAdmin,
  validate(adminAnalyticsSchema),
  asyncHandler(async (req, res) => {
    const q = validatedQuery(req);
    ok(res, await getPlatformFunnelAnalytics({ days: q.days ?? 30 }));
  }),
);

adminRoutes.get(
  "/call-logs",
  requireAdmin,
  validate(adminCallLogsSchema),
  asyncHandler(async (req, res) => {
    const result = await adminService.listAllCallLogs(validatedQuery(req));
    ok(res, result.items, 200, result.meta);
  }),
);

adminRoutes.get(
  "/categories",
  requireAdmin,
  asyncHandler(async (_req, res) => {
    ok(res, await adminService.listCategories());
  }),
);

adminRoutes.post(
  "/categories",
  requireAdmin,
  validate(categoryCreateSchema),
  asyncHandler(async (req, res) => {
    created(res, await adminService.createCategory(req.body));
  }),
);

adminRoutes.patch(
  "/categories/reorder",
  requireAdmin,
  validate(categoryReorderSchema),
  asyncHandler(async (req, res) => {
    ok(res, await adminService.reorderCategories(req.body));
  }),
);

adminRoutes.patch(
  "/categories/:id",
  requireAdmin,
  validate(categoryPatchSchema),
  asyncHandler(async (req, res) => {
    ok(res, await adminService.patchCategory(req.params.id, req.body));
  }),
);

adminRoutes.delete(
  "/categories/:id",
  requireAdmin,
  validate(idParamSchema),
  asyncHandler(async (req, res) => {
    ok(res, await adminService.removeCategory(req.params.id));
  }),
);

adminRoutes.get(
  "/vehicle-types",
  requireAdmin,
  asyncHandler(async (req, res) => {
    const isEnabled = req.query.isEnabled !== undefined ? req.query.isEnabled === "true" : undefined;
    ok(res, await adminService.listVehicleTypes({ categoryId: req.query.categoryId, isEnabled }));
  }),
);

adminRoutes.post(
  "/vehicle-types",
  requireAdmin,
  validate(vehicleTypeCreateSchema),
  asyncHandler(async (req, res) => {
    created(res, await adminService.createVehicleType(req.body));
  }),
);

adminRoutes.patch(
  "/vehicle-types/:id",
  requireAdmin,
  validate(vehicleTypePatchSchema),
  asyncHandler(async (req, res) => {
    ok(res, await adminService.patchVehicleType(req.params.id, req.body));
  }),
);

adminRoutes.delete(
  "/vehicle-types/:id",
  requireAdmin,
  validate(idParamSchema),
  asyncHandler(async (req, res) => {
    ok(res, await adminService.removeVehicleType(req.params.id));
  }),
);

adminRoutes.get(
  "/cities",
  requireAdmin,
  asyncHandler(async (req, res) => {
    const enabledOnly = req.query.enabledOnly === "true";
    ok(res, await adminService.listCities({ enabledOnly }));
  }),
);

adminRoutes.post(
  "/cities",
  requireAdmin,
  validate(cityCreateSchema),
  asyncHandler(async (req, res) => {
    created(res, await adminService.createCity(req.body));
  }),
);

adminRoutes.patch(
  "/cities/:id",
  requireAdmin,
  validate(cityPatchSchema),
  asyncHandler(async (req, res) => {
    ok(res, await adminService.patchCity(req.params.id, req.body));
  }),
);

adminRoutes.delete(
  "/cities/:id",
  requireAdmin,
  validate(idParamSchema),
  asyncHandler(async (req, res) => {
    ok(res, await adminService.removeCity(req.params.id));
  }),
);

adminRoutes.post(
  "/translate",
  requireAdmin,
  asyncHandler(async (req, res) => {
    const text = req.body?.text || req.query?.text || "";
    const translated = await autoTranslateToArabic(text);
    ok(res, { text, translated });
  }),
);

adminRoutes.get(
  "/translate",
  requireAdmin,
  asyncHandler(async (req, res) => {
    const text = req.query?.text || "";
    const translated = await autoTranslateToArabic(text);
    ok(res, { text, translated });
  }),
);

adminRoutes.get(
  "/category-assets",
  requireAdmin,
  asyncHandler(async (_req, res) => {
    ok(res, await adminService.listCategoryAssets());
  }),
);

adminRoutes.post(
  "/category-assets",
  requireAdmin,
  asyncHandler(async (req, res) => {
    created(res, await adminService.addCategoryAsset(req.body));
  }),
);

adminRoutes.delete(
  "/category-assets/:id",
  requireAdmin,
  asyncHandler(async (req, res) => {
    ok(res, await adminService.removeCategoryAsset(req.params.id));
  }),
);
