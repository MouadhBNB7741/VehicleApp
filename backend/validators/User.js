import * as zod from "zod";

const RoleEnum = zod.enum(["USER", "PARTNER", "ADMIN"]);

export const registerUserSchema = zod
  .object({
    fullName: zod.string().min(3, "Full name must be at least 3 characters"),
    email: zod.string().email("Invalid email address").optional(),
    phoneNumber: zod
      .string()
      .min(9, "Phone number is too short")
      .max(13, "Phone number is too long")
      .optional(),
    password: zod.string().min(8, "Password must be at least 8 characters"),
    role: RoleEnum,
  })
  .refine((data) => data.email || data.phoneNumber, {
    message: "Either email or phone number is required",
    path: ["email"],
  });

export const updateUserSchema = registerUserSchema
  .omit({ role: true })
  .partial();

export const loginUserSchema = zod
  .object({
    email: zod.string().email().optional(),
    phoneNumber: zod.string().min(9).max(13).optional(),
    password: zod.string().min(8),
  })
  .refine((data) => data.email || data.phoneNumber, {
    message: "Either email or phone number is required",
    path: ["email"],
  });

export const getUserByIdSchema = zod.object({
  id: zod.string().cuid(),
});

export const searchUsersSchema = zod.object({
  search: zod.string().optional(),
  role: RoleEnum.optional(),
  limit: zod
    .string()
    .optional()
    .transform(Number)
    .pipe(zod.number().int().positive().max(100)),
  page: zod
    .string()
    .optional()
    .transform(Number)
    .pipe(zod.number().int().positive()),
});
