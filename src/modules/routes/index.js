import { Router } from "express";
import { publicRoutes } from "./public.routes.js";
import { providerRoutes } from "./provider.routes.js";
import { adminRoutes } from "./admin.routes.js";
import { discoveryRoutes } from "./discovery.routes.js";
import { customerRoutes } from "./customer.routes.js";

export const apiRouter = Router();

apiRouter.use(publicRoutes);
apiRouter.use("/discovery", discoveryRoutes);
apiRouter.use("/customers", customerRoutes);
apiRouter.use("/customer", customerRoutes);
apiRouter.use("/providers", providerRoutes);
apiRouter.use("/provider", providerRoutes);
apiRouter.use("/admin", adminRoutes);
