import { Router } from "express";
import {
  sendNotificationToUser,
  sendNotificationToPartner,
  markNotificationAsRead,
  getAllNotificationsForUser,
  getAllNotificationsForPartner,
} from "../controllers/NotificationController.js";
import { authMiddleware } from "../middlewares/User.js";

const notificationsRouter = Router();

// Protected routes
notificationsRouter.use(authMiddleware);

// Send Notifications
notificationsRouter.post("/user", sendNotificationToUser);
notificationsRouter.post("/partner", sendNotificationToPartner);

// Mark as read
notificationsRouter.patch("/:id/read", markNotificationAsRead);

// Get Notifications
notificationsRouter.get("/user/:userId", getAllNotificationsForUser);
notificationsRouter.get("/partner/:partnerId", getAllNotificationsForPartner);

export default notificationsRouter;
