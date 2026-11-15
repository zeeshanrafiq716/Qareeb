import { query } from "../../db/pool.js";
import { Router } from "express";
import { asyncHandler } from "../../utils/asyncHandler.js";
import { ok } from "../../utils/http.js";
import { validate } from "../../middleware/validate.js";
import { otpRequestSchema, otpVerifySchema, loginSchema, setPasswordSchema } from "../schemas.js";
import * as authService from "../auth.service.js";
import { otpRequestRateLimit, otpVerifyRateLimit } from "../../middleware/rateLimit.js";
import * as providerService from "../providers.service.js";
import { serializeCategory } from "../serializers.js";

export const publicRoutes = Router();

publicRoutes.get("/health", (_req, res) => {
  ok(res, { status: "healthy", phase: 5 });
});

publicRoutes.get(
  "/cities",
  asyncHandler(async (_req, res) => {
    res.setHeader("Cache-Control", "no-cache, no-store, must-revalidate, proxy-revalidate");
    try {
      const { rows } = await query(
        `SELECT id, name, name_ar, latitude, longitude, zoom, sort_order 
         FROM cities 
         WHERE is_enabled = true 
         ORDER BY sort_order ASC, name ASC`
      );
      ok(
        res,
        rows.map((r) => ({
          id: r.id,
          name: r.name,
          nameAr: r.name_ar,
          name_ar: r.name_ar,
          latitude: parseFloat(r.latitude),
          longitude: parseFloat(r.longitude),
          lat: parseFloat(r.latitude),
          lng: parseFloat(r.longitude),
          zoom: parseInt(r.zoom, 10) || 13,
          sortOrder: r.sort_order,
        }))
      );
    } catch (_) {
      ok(res, []);
    }
  }),
);

publicRoutes.get(
  "/categories",
  asyncHandler(async (_req, res) => {
    res.setHeader("Cache-Control", "no-cache, no-store, must-revalidate, proxy-revalidate");
    res.setHeader("Pragma", "no-cache");
    res.setHeader("Expires", "0");
    res.setHeader("Surrogate-Control", "no-store");
    const rows = await providerService.listEnabledCategories();
    ok(res, rows.map(serializeCategory));
  }),
);

publicRoutes.get(
  "/categories/vehicle-types",
  asyncHandler(async (req, res) => {
    res.setHeader("Cache-Control", "no-cache, no-store, must-revalidate, proxy-revalidate");
    res.setHeader("Pragma", "no-cache");
    res.setHeader("Expires", "0");
    res.setHeader("Surrogate-Control", "no-store");
    try {
      const { rows } = await query(
        `SELECT id, name, name_ar, slug FROM vehicle_types WHERE is_enabled = true ORDER BY sort_order ASC, name ASC`,
      );
      if (req.query.details === "1" || req.query.details === "true") {
        return ok(
          res,
          rows.map((r) => ({
            id: r.id,
            name: r.name,
            nameAr: r.name_ar || null,
            name_ar: r.name_ar || null,
            slug: r.slug,
          })),
        );
      }
      const isArabic =
        req.query.lang === "ar" ||
        req.headers["accept-language"]?.startsWith("ar");
      return ok(
        res,
        rows.map((r) => (isArabic && r.name_ar ? r.name_ar : r.name)),
      );
    } catch (_) {
      const rows = await providerService.listEnabledCategories();
      return ok(res, rows.map((r) => r.name));
    }
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
        channel: req.body.channel,
        userType: req.body.userType,
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
    ok(
      res,
      await authService.verifyOtp(req.body.phone, req.body.otp, {
        password: req.body.password,
        name: req.body.name,
        userType: req.body.userType,
      }),
    );
  }),
);

publicRoutes.post(
  "/auth/login",
  validate(loginSchema),
  asyncHandler(async (req, res) => {
    ok(
      res,
      await authService.loginWithPassword({
        phone: req.body.phone,
        password: req.body.password,
        userType: req.body.userType,
      }),
    );
  }),
);

publicRoutes.post(
  "/auth/password/set",
  validate(setPasswordSchema),
  asyncHandler(async (req, res) => {
    ok(
      res,
      await authService.setPassword({
        phone: req.body.phone,
        password: req.body.password,
        userType: req.body.userType,
        name: req.body.name,
      }),
    );
  }),
);

publicRoutes.post(
  "/support/tickets",
  asyncHandler(async (req, res) => {
    const { category, description, phone, name, photos, source } = req.body;
    if (!description || !description.trim()) {
      return res.status(400).json({ success: false, error: "Description is required" });
    }
    const ticketNumber = `TKT-${Math.floor(100000 + Math.random() * 900000)}`;
    const { rows } = await query(
      `INSERT INTO support_tickets (ticket_number, category, description, customer_phone, customer_name, photos, source)
       VALUES ($1, $2, $3, $4, $5, $6, $7)
       RETURNING id, ticket_number, category, description, customer_phone, customer_name, photos, status, source, created_at`,
      [
        ticketNumber,
        category || "General Support",
        description.trim(),
        phone || null,
        name || null,
        JSON.stringify(photos || []),
        source || "customer_mobile",
      ]
    );

    return ok(res, rows[0], 201);
  }),
);
