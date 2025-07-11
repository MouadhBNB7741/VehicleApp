import { Router } from "express";
import {
  calculateAndApplyTax,
  createTransaction,
  getAllTransactions,
  getTransactionByRequestId,
  getTransactionsByPartnerId,
  getTransactionsByUserId,
  refundTransaction,
  updateTransactionStatus,
} from "../controllers/TransactionController.js";
import { authMiddleware } from "../middlewares/User.js";

const transactionRouter = Router();

transactionRouter.post("/create", authMiddleware, createTransaction);
transactionRouter.get("/:requestId", authMiddleware, getTransactionByRequestId);
transactionRouter.get("/", authMiddleware, getAllTransactions);
transactionRouter.get("/user/:userId", authMiddleware, getTransactionsByUserId);
transactionRouter.get(
  "/partner/:partnerId",
  authMiddleware,
  getTransactionsByPartnerId
);
transactionRouter.patch("/:id/status", authMiddleware, updateTransactionStatus);
transactionRouter.patch("/:id/refund", authMiddleware, refundTransaction);
transactionRouter.patch(
  "/:id/calculate-tax",
  authMiddleware,
  calculateAndApplyTax
);

export default transactionRouter;
