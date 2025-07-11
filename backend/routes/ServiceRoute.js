import { Router } from "express";
import {
  getAllServiceTypes,
  getServicesByCategory,
  addNewServiceType,
  updateServiceType,
  deleteServiceType,
} from "../controllers/ServiceController.js";
import { authMiddleware, roleMiddleware } from "../middlewares/User.js";

const serviceRouter = Router();

// Public routes
serviceRouter.get("/", getAllServiceTypes);
serviceRouter.get("/category/:category", getServicesByCategory);

// Admin-only routes
serviceRouter.post(
  "/create",
  authMiddleware,
  roleMiddleware(["ADMIN"]),
  addNewServiceType
);
serviceRouter.put(
  "/:id",
  authMiddleware,
  roleMiddleware(["ADMIN"]),
  updateServiceType
);
serviceRouter.delete(
  "/:id/delete",
  authMiddleware,
  roleMiddleware(["ADMIN"]),
  deleteServiceType
);

export default serviceRouter;
