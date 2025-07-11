import * as zod from "zod";

export const createServiceTypeSchema = zod.object({
  name: zod.string().min(2),
  category: zod.string().min(2),
  description: zod.string().optional(),
});

export const updateServiceTypeSchema = createServiceTypeSchema.partial();

export const getServiceByCategorySchema = zod.object({
  category: zod.string().min(2),
});
