import * as zod from "zod";

export const updateUserLocationSchema = zod.object({
  userId: zod.string().cuid(),
  latitude: zod.number().min(-90).max(90),
  longitude: zod.number().min(-180).max(180),
});

export const updatePartnerLocationSchema = zod.object({
  partnerId: zod.string().cuid(),
  latitude: zod.number().min(-90).max(90),
  longitude: zod.number().min(-180).max(180),
});

export const getNearbyPartnersSchema = zod.object({
  latitude: zod.number().min(-90).max(90),
  longitude: zod.number().min(-180).max(180),
  radiusKm: zod.number().optional().default(50),
});
