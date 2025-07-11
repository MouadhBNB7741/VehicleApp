import * as zod from "zod";

export const createTransactionSchema = zod.object({
  requestId: zod.string().cuid(),
  partnerId: zod.string().cuid(),
  amount: zod.number().positive(),
});

export const updateTransactionStatusSchema = zod.object({
  paymentStatus: zod.enum(["PAID", "UNPAID", "REFUNDED"]),
});
