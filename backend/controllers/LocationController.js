import prisma from "../services/prisma.js";
import {
  getNearbyPartnersSchema,
  updatePartnerLocationSchema,
  updateUserLocationSchema,
} from "../validators/Location.js";
import * as z from "zod";

//TODO after the submittion need to be changed to google api or alternative solution
function getDistance(lat1, lon1, lat2, lon2) {
  const R = 6371;
  const dLat = ((lat2 - lat1) * Math.PI) / 180;
  const dLon = ((lon2 - lon1) * Math.PI) / 180;

  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos((lat1 * Math.PI) / 180) *
      Math.cos((lat2 * Math.PI) / 180) *
      Math.sin(dLon / 2) *
      Math.sin(dLon / 2);

  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}

export async function updateUserLocation(req, res) {
  try {
    const { userId, latitude, longitude } = updateUserLocationSchema.parse(
      req.body
    );

    const updatedLocation = await prisma.userLocation.upsert({
      where: { userId },
      update: {
        create: {
          userId,
          location: {
            create: {
              latitude,
              longitude,
            },
          },
        },
        location: {
          location: {
            upsert: {
              create: { latitude, longitude },
              update: { latitude, longitude },
            },
          },
        },
      },
      include: {
        location: true,
      },
    });

    return res.json(updatedLocation);
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: error.errors });
    }

    console.error("Update user location error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}

export async function updatePartnerLocation(req, res) {
  try {
    const { partnerId, latitude, longitude } =
      updatePartnerLocationSchema.parse(req.body);

    const updatedLocation = await prisma.partner.update({
      where: { id: partnerId },
      data: {
        isAvailable: true,
        location: {
          upsert: {
            create: {
              latitude,
              longitude,
            },
            update: {
              latitude,
              longitude,
            },
          },
        },
      },
      include: {
        location: true,
      },
    });

    return res.json(updatedLocation);
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: error.errors });
    }

    console.error("Update partner location error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}

export async function getLocationByUserId(req, res) {
  const { userId } = req.params;

  try {
    const userLocation = await prisma.userLocation.findUnique({
      where: { userId },
      include: {
        location: true,
      },
    });

    if (!userLocation || !userLocation.location) {
      return res.status(404).json({ error: "Location not found" });
    }

    return res.json(userLocation.location);
  } catch (error) {
    console.error("Get location by user error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}

export async function getLocationByPartnerId(req, res) {
  const { partnerId } = req.params;

  try {
    const partner = await prisma.partner.findUnique({
      where: { id: partnerId },
      include: {
        location: true,
      },
    });

    if (!partner || !partner.location) {
      return res.status(404).json({ error: "Location not found" });
    }

    return res.json(partner.location);
  } catch (error) {
    console.error("Get location by partner error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}

export async function getNearestPartners(req, res) {
  try {
    const { latitude, longitude, radiusKm } = getNearbyPartnersSchema.parse(
      req.query
    );

    const partners = await prisma.partner.findMany({
      where: {
        isAvailable: true,
        location: {
          NOT: null,
        },
      },
      include: {
        location: true,
        user: true,
      },
    });

    const nearbyPartners = partners
      .map((partner) => {
        if (!partner.location) return null;

        const dist = getDistance(
          latitude,
          longitude,
          partner.location.latitude,
          partner.location.longitude
        );
        return {
          ...partner,
          distanceKm: dist.toFixed(2),
        };
      })
      .filter((partner) => partner.distanceKm <= radiusKm)
      .sort((a, b) => a.distanceKm - b.distanceKm);

    return res.json(nearbyPartners);
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: error.errors });
    }

    console.error("Get nearest partners error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}
