import * as zod from "zod";

export const applyToBecomePartnerSchema = zod.object({
  userId: zod.string().cuid(),
  businessName: zod.string().min(2),
  description: zod.string().optional(),
  serviceTypeId: zod.number().int(),
  locationId: zod.number().int().optional(),
});

export const updatePartnerProfileSchema = applyToBecomePartnerSchema
  .omit({ userId: true })
  .partial();

export const getPartnersByServiceTypeSchema = zod.object({
  serviceTypeId: zod.number().int(),
});

export const getAvailablePartnersByLocationSchema = zod.object({
  latitude: zod.number(),
  longitude: zod.number(),
  radiusKm: zod.number().optional().default(50),
});

export const updatePartnerAvailabilitySchema = zod.object({
  isAvailable: zod.boolean(),
});
