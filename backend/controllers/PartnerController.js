import prisma from "../services/prisma.js";
import {
  applyToBecomePartnerSchema,
  updatePartnerProfileSchema,
  getPartnersByServiceTypeSchema,
  getAvailablePartnersByLocationSchema,
  updatePartnerAvailabilitySchema,
} from "../validators/Partner.js";
import * as z from "zod";

//TODO add multer for cv photo
export async function applyToBecomePartner(req, res) {
  try {
    const data = applyToBecomePartnerSchema.parse(req.body);

    const application = await prisma.partnerApplication.create({
      data: {
        ...data,
        status: "PENDING",
        userId: data.userId,
      },
    });

    return res.status(201).json({
      message: "Application submitted successfully",
      application,
    });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: error.errors });
    }

    console.error("Apply to become partner error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}

export async function updatePartnerProfile(req, res) {
  const { id } = req.params;

  try {
    const data = updatePartnerProfileSchema.parse(req.body);

    const updatedPartner = await prisma.partner.update({
      where: { id },
      data,
    });

    return res.json(updatedPartner);
  } catch (error) {
    if (error.code === "P2025") {
      return res.status(404).json({ error: "Partner not found" });
    }

    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: error.errors });
    }

    console.error("Update partner profile error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}

export async function getAllPartners(req, res) {
  try {
    const partners = await prisma.partner.findMany();

    return res.json(partners);
  } catch (error) {
    console.error("Get all partners error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}

export async function getPartnerById(req, res) {
  const { id } = req.params;

  try {
    const partner = await prisma.partner.findUnique({
      where: { id },
      include: {
        user: true,
        serviceType: true,
        location: true,
      },
    });

    if (!partner) {
      return res.status(404).json({ error: "Partner not found" });
    }

    return res.json(partner);
  } catch (error) {
    console.error("Get partner by ID error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}

export async function getPartnersByServiceType(req, res) {
  try {
    const { serviceTypeId } = getPartnersByServiceTypeSchema.parse(req.query);

    const partners = await prisma.partner.findMany({
      where: {
        serviceTypeId,
        isAvailable: true,
      },
      include: {
        user: true,
        serviceType: true,
      },
    });

    return res.json(partners);
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: error.errors });
    }

    console.error("Get partners by service type error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}

export async function getAvailablePartnersByLocation(req, res) {
  try {
    const { latitude, longitude, radiusKm } =
      getAvailablePartnersByLocationSchema.parse(req.query);

    const partners = await prisma.partner.findMany({
      where: {
        location: {
          latitude: {
            gte: latitude - radiusKm / 111,
            lte: latitude + radiusKm / 111,
          },
          longitude: {
            gte: longitude - radiusKm / 111,
            lte: longitude + radiusKm / 111,
          },
        },
        isAvailable: true,
      },
      include: {
        user: true,
        serviceType: true,
        location: true,
      },
    });

    return res.json(partners);
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: error.errors });
    }

    console.error("Get available partners by location error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}

export async function updatePartnerAvailability(req, res) {
  const { id } = req.params;

  try {
    const { isAvailable } = updatePartnerAvailabilitySchema.parse(req.body);

    const updatedPartner = await prisma.partner.update({
      where: { id },
      data: { isAvailable },
    });

    return res.json({
      message: `Partner is now ${isAvailable ? "available" : "unavailable"}`,
      partner: updatedPartner,
    });
  } catch (error) {
    if (error.code === "P2025") {
      return res.status(404).json({ error: "Partner not found" });
    }

    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: error.errors });
    }

    console.error("Update partner availability error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}
