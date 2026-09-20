import { Router } from "express";
import { asyncHandler } from "../../utils/asyncHandler.js";
import { created, ok } from "../../utils/http.js";
import { validate, validatedParams, validatedQuery } from "../../middleware/validate.js";
import {
  customerFunnelEventSchema,
  discoverySearchSchema,
  nearbyDiscoverySchema,
  publicProviderParamSchema,
} from "../schemas.js";
import {
  findNearbyProvidersForCustomers,
  getPublicProviderProfile,
  listDiscoveryCategories,
  searchDiscovery,
} from "../discovery.service.js";
import { trackCustomerDiscoveryEvent } from "../funnel.service.js";

function customerSessionId(req, querySessionId) {
  const header = req.get("X-Customer-Session")?.trim();
  return header || querySessionId?.trim() || undefined;
}

/** Customer discovery — privacy-safe. Customers never appear on provider maps. */
export const discoveryRoutes = Router();

discoveryRoutes.get(
  "/categories",
  asyncHandler(async (_req, res) => {
    ok(res, await listDiscoveryCategories());
  }),
);

discoveryRoutes.get(
  "/search",
  validate(discoverySearchSchema),
  asyncHandler(async (req, res) => {
    const q = validatedQuery(req);
    const result = await searchDiscovery({
      ...q,
      sessionId: customerSessionId(req, q.sessionId),
    });
    ok(res, { list: result.list, map: result.map }, 200, result.meta);
  }),
);

discoveryRoutes.get(
  "/nearby",
  validate(nearbyDiscoverySchema),
  asyncHandler(async (req, res) => {
    const result = await findNearbyProvidersForCustomers(validatedQuery(req));
    ok(res, result.items, 200, result.meta);
  }),
);

discoveryRoutes.get(
  "/providers/:publicId",
  validate(publicProviderParamSchema),
  asyncHandler(async (req, res) => {
    const q = validatedQuery(req);
    ok(
      res,
      await getPublicProviderProfile(
        validatedParams(req).publicId,
        q.latitude,
        q.longitude,
        { sessionId: customerSessionId(req, q.sessionId) },
      ),
    );
  }),
);

discoveryRoutes.post(
  "/events",
  validate(customerFunnelEventSchema),
  asyncHandler(async (req, res) => {
    created(res, await trackCustomerDiscoveryEvent(req.body));
  }),
);
