import { Router } from "express";
import {
  approvePartnerApplication,
  declinePartnerApplication,
  banPartner,
  unbanPartner,
  getAllReports,
  resolveReport,
  deleteUserOrPartner,
} from "../controllers/AdminController.js";
import { authMiddleware, roleMiddleware } from "../middlewares/User.js";

const adminRouter = Router();

// Auth middleware + admin only
adminRouter.use(authMiddleware, roleMiddleware(["ADMIN"]));

// Partner Applications
adminRouter.post("/applications/approve", approvePartnerApplication);
adminRouter.post("/applications/decline", declinePartnerApplication);

// Partner Management
adminRouter.post("/partner/ban", banPartner);
adminRouter.post("/partner/unban/:id", unbanPartner);

// Reports
adminRouter.get("/reports", getAllReports);
adminRouter.patch("/report/resolve/:reportId", resolveReport);

// Delete Users or Partners
adminRouter.delete("/entity/:id", deleteUserOrPartner);

export default adminRouter;
