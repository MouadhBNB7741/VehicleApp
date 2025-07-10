import { Router } from "express";
import {
  checkGuaranteeValidity,
  getAllVerifications,
  getGuaranteeByVerificationId,
  getVerificationById,
  getVerificationsByUserId,
  issueGuarantee,
  requestCarVerification,
  verifyCar,
} from "../controllers/GuarenteeController.js";
import { authMiddleware, roleMiddleware } from "../middlewares/User.js";

const carVerificationRouter = Router();

// Public routes
carVerificationRouter.get("/:verificationId/guarantee", checkGuaranteeValidity);
carVerificationRouter.get(
  "/:verificationId/guarantee/details",
  getGuaranteeByVerificationId
);

// need to be a user
carVerificationRouter.post("/request", authMiddleware, requestCarVerification);

// Admin-only routes
carVerificationRouter.get(
  "/all",
  authMiddleware,
  roleMiddleware(["ADMIN"]),
  getAllVerifications
);
carVerificationRouter.get("/:id", authMiddleware, getVerificationById);
carVerificationRouter.patch(
  "/:id/verify",
  authMiddleware,
  roleMiddleware(["ADMIN"]),
  verifyCar
);
carVerificationRouter.post(
  "/:id/guarantee",
  authMiddleware,
  roleMiddleware(["ADMIN"]),
  issueGuarantee
);

// Get by user
carVerificationRouter.get(
  "/user/:userId",
  authMiddleware,
  getVerificationsByUserId
);

export default carVerificationRouter;
