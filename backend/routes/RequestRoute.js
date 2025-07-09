import { Router } from "express";
import {
  createRequestForHelp,
  getAllRequests,
  getRequestById,
  getRequestsByUserId,
  getRequestsByPartnerId,
  updateRequestStatus,
  cancelRequest,
  completeRequest,
  getRequestsByServiceType,
  getNearbyActiveRequests,
} from "../controllers/RequestController.js";
import { authMiddleware } from "../middlewares/auth.middleware.js";

const requestRouter = Router();

// Public route for creating request
requestRouter.post("/create", authMiddleware, createRequestForHelp);

// Protected routes
requestRouter.get("/", authMiddleware, getAllRequests);
requestRouter.get("/:id", authMiddleware, getRequestById);
requestRouter.get("/user/:userId", authMiddleware, getRequestsByUserId);
requestRouter.get(
  "/partner/:partnerId",
  authMiddleware,
  getRequestsByPartnerId
);
requestRouter.patch("/:id/status", authMiddleware, updateRequestStatus);
requestRouter.patch("/:id/cancel", authMiddleware, cancelRequest);
requestRouter.patch("/:id/complete", authMiddleware, completeRequest);
requestRouter.get(
  "/service/:serviceTypeId",
  authMiddleware,
  getRequestsByServiceType
);
requestRouter.get("/nearby", authMiddleware, getNearbyActiveRequests);

export default requestRouter;
