import * as zod from "zod";

export const createReportSchema = zod.object({
  reporterId: zod.string().cuid(),
  partnerId: zod.string().cuid(),
  reason: zod.string().min(10),
  evidenceUrl: zod.string().url().optional(),
});

export const resolveReportSchema = zod.object({
  adminNotes: zod.string().optional(),
});

export const getReportsByUserSchema = zod.object({
  userId: zod.string().cuid(),
});

export const getReportsByPartnerSchema = zod.object({
  partnerId: zod.string().cuid(),
});
