import { Router } from "express";
import { asyncHandler } from "../../utils/asyncHandler.js";
import { ok } from "../../utils/http.js";
import { requireCustomer } from "../../middleware/auth.js";

export const customerRoutes = Router();

customerRoutes.get(
  "/me",
  requireCustomer,
  asyncHandler(async (req, res) => {
    ok(res, {
      id: req.customer.id,
      phone: req.customer.phone,
      name: req.customer.name,
      status: req.customer.status,
    });
  }),
);