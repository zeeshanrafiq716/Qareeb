import { Router } from "express";
import { publicRoutes } from "./public.routes.js";
import { providerRoutes } from "./provider.routes.js";
import { adminRoutes } from "./admin.routes.js";
import { discoveryRoutes } from "./discovery.routes.js";

export const apiRouter = Router();

apiRouter.use(publicRoutes);
apiRouter.use("/discovery", discoveryRoutes);
apiRouter.use("/providers", providerRoutes);
apiRouter.use("/admin", adminRoutes);
