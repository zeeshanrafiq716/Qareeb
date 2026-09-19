import { Router } from "express";
import { asyncHandler } from "../../utils/asyncHandler.js";
import { created, ok } from "../../utils/http.js";
import { validate, validatedQuery } from "../../middleware/validate.js";
import { requireAdmin } from "../../middleware/auth.js";
import {
  adminLoginSchema,
  categoryCreateSchema,
  categoryPatchSchema,
  idParamSchema,
  optionalReasonSchema,
  providerListSchema,
  reasonSchema,
} from "../schemas.js";
import * as adminService from "../admin.service.js";

export const adminRoutes = Router();

adminRoutes.post(
  "/auth/login",
  validate(adminLoginSchema),
  asyncHandler(async (req, res) => {
    ok(res, await adminService.adminLogin(req.body.email, req.body.password));
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
  validate(reasonSchema),
  asyncHandler(async (req, res) => {
    ok(res, await adminService.suspendProvider(req.params.id, req.admin, req.body.reason));
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
    created(res, await adminService.createCategory(req.body.name));
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
