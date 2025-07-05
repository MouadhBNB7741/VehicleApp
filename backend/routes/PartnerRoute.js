import express from "express";
import {
  applyToBecomePartner,
  updatePartnerProfile,
  getAllPartners,
  getPartnerById,
  getPartnersByServiceType,
  getAvailablePartnersByLocation,
  updatePartnerAvailability,
} from "../controllers/PartnerController.js";
import { authMiddleware, roleMiddleware } from "../middlewares/User.js";

const router = express.Router();

// Public route
router.post("/apply", authMiddleware, applyToBecomePartner);

// Protected routes
router.get("/", authMiddleware, roleMiddleware(["ADMIN"]), getAllPartners);
router.get("/:id", authMiddleware, getPartnerById);
router.put(
  "/:id",
  authMiddleware,
  roleMiddleware(["ADMIN", "PARTNER"]),
  updatePartnerProfile
);
router.patch(
  "/:id/availability",
  authMiddleware,
  roleMiddleware(["ADMIN", "PARTNER"]),
  updatePartnerAvailability
);

// Search routes
router.get("/service/:serviceTypeId", authMiddleware, getPartnersByServiceType);
router.get("/location", authMiddleware, getAvailablePartnersByLocation);

export default router;
