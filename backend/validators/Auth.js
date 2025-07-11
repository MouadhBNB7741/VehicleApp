import * as zod from "zod";

export const verifyEmailSchema = zod.object({
  userId: zod.string().cuid(),
});

export const resetPasswordSchema = zod.object({
  newPassword: zod.string().min(8),
  token: zod.string(),
});

export const changePasswordSchema = zod.object({
  oldPassword: zod.string().min(8),
  newPassword: zod.string().min(8),
});
