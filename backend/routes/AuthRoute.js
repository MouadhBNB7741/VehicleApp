import { Router } from "express";
import {
  sendEmailVerification,
  verifyEmail,
  sendPasswordResetEmail,
  resetPassword,
  changePassword,
} from "../controllers/AuthController.js";
import { authMiddleware } from "../middlewares/User.js";

const authRouter = Router();

// Public routes
authRouter.post("/email/verify", authMiddleware, sendEmailVerification);
authRouter.get("/email/verify/:token", verifyEmail);

authRouter.post("/password/forgot", sendPasswordResetEmail);
authRouter.post("/password/reset/:token", resetPassword);

// Protected routes
authRouter.use(authMiddleware);

authRouter.post("/password/change", changePassword);

export default authRouter;
