import * as zod from "zod";

export const requestCarVerificationSchema = zod.object({
  userId: zod.string().cuid(),
  vinNumber: zod.string().min(10),
  carModel: zod.string().min(2),
  year: zod.number().int().min(1900).max(2100),
  mileage: zod.number().int().positive(),
});

export const verifyCarSchema = zod.object({
  adminId: zod.string().cuid(),
  status: zod.enum(["VERIFIED", "REJECTED"]),
});

export const issueGuaranteeSchema = zod.object({
  validUntil: zod.date(),
  terms: zod.string().min(10),
});
