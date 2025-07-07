import * as zod from "zod";

export const approvePartnerSchema = zod.object({
  applicationId: zod.string().cuid(),
});

export const declinePartnerSchema = zod.object({
  applicationId: zod.string().cuid(),
  reason: zod.string().optional(),
});

export const banPartnerSchema = zod.object({
  partnerId: zod.string().cuid(),
  reason: zod.string().optional(),
});

export const deleteEntitySchema = zod.object({
  id: zod.string().cuid(),
});
