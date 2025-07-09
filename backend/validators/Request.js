import * as zod from "zod";

export const createRequestSchema = zod.object({
  userId: zod.string().cuid(),
  serviceTypeId: zod.number().int(),
  locationId: zod.number().int(),
  description: zod.string().optional(),
});

export const updateRequestStatusSchema = zod.object({
  status: zod.enum(["PENDING", "ACCEPTED", "CANCELLED", "COMPLETED"]),
  partnerId: zod.string().cuid().optional(),
});

export const getRequestsByUserSchema = zod.object({
  userId: zod.string().cuid(),
});

export const getRequestsByPartnerSchema = zod.object({
  partnerId: zod.string().cuid(),
});

export const getRequestsByServiceTypeSchema = zod.object({
  serviceTypeId: zod.number().int(),
});

export const getNearbyRequestsSchema = zod.object({
  latitude: zod.number(),
  longitude: zod.number(),
  radiusKm: zod.number().optional().default(50),
});
