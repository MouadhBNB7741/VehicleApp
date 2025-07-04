import { Router } from "express";
import {
  registerUser,
  login,
  getCurrentUserProfile,
  updateUserProfile,
  getUserById,
  searchUsers,
  logout,
  adminCreateUser,
} from "../controllers/UserController.js";
import { authMiddleware, roleMiddleware } from "../middlewares/User.js";

const router = Router();

router.post("/register", registerUser);
router.post("/login", login);

// Protected routes
router.get("/me", authMiddleware, getCurrentUserProfile);
router.put("/me", authMiddleware, updateUserProfile);
router.get("/:id", authMiddleware, getUserById);
router.get("/", authMiddleware, searchUsers);
router.post(
  "/admin",
  authMiddleware,
  roleMiddleware(["ADMIN"]),
  adminCreateUser
);

// Logout
router.post("/logout", authMiddleware, logout);

export default router;
