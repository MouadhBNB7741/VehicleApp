import * as zod from "zod";

export const sendNotificationToUserSchema = zod.object({
  userId: zod.string().cuid(),
  message: zod.string().min(5),
  type: zod.string().optional(), //can be changed to enum
});

export const sendNotificationToPartnerSchema = zod.object({
  partnerId: zod.string().cuid(),
  message: zod.string().min(5),
  type: zod.string().optional(),
});
