import { Router } from "express";
import {
  getAllReports,
  getReportById,
  getReportsByPartnerId,
  getReportsByUserId,
  resolveReport,
} from "../controllers/ReportController.js";
import {
  authMiddleware,
  roleMiddleware,
} from "../middlewares/auth.middleware.js";

const reportRouter = Router();

// Public route
reportRouter.post("/create", authMiddleware, submitReportOnPartner);

reportRouter.get("/user/:userId", authMiddleware, getReportsByUserId);
reportRouter.get("/partner/:partnerId", authMiddleware, getReportsByPartnerId);

// Admin-only routes
reportRouter.get(
  "/all",
  authMiddleware,
  roleMiddleware(["ADMIN"]),
  getAllReports
);
reportRouter.get("/:id", authMiddleware, getReportById);
reportRouter.patch(
  "/:id/resolve",
  authMiddleware,
  roleMiddleware(["ADMIN"]),
  resolveReport
);

export default reportRouter;
