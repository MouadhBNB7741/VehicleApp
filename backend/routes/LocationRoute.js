import { Router } from "express";
import {
  updateUserLocation,
  updatePartnerLocation,
  getLocationByUserId,
  getLocationByPartnerId,
  getNearestPartners,
} from "../controllers/LocationController.js";
import { authMiddleware } from "../middlewares/User.js";

const locationRouter = Router();

// Public route: anyone can search nearby
locationRouter.get("/nearby", getNearestPartners);

// Protected routes
locationRouter.post("/user/update", authMiddleware, updateUserLocation);
locationRouter.post("/partner/update", authMiddleware, updatePartnerLocation);
locationRouter.get("/:userId/user", authMiddleware, getLocationByUserId);
locationRouter.get(
  "/:partnerId/partner",
  authMiddleware,
  getLocationByPartnerId
);

export default locationRouter;
