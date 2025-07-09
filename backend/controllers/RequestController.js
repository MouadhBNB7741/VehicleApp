import prisma from "../services/prisma.js";
import {
  createRequestSchema,
  updateRequestStatusSchema,
  getRequestsByUserSchema,
  getRequestsByPartnerSchema,
  getRequestsByServiceTypeSchema,
  getNearbyRequestsSchema,
} from "../validators/Request.js";
import * as z from "zod";

export async function createRequestForHelp(req, res) {
  try {
    const data = createRequestSchema.parse(req.body);

    const newRequest = await prisma.request.create({
      data: {
        ...data,
        status: "PENDING",
      },
    });

    return res.status(201).json(newRequest);
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: error.errors });
    }

    console.error("Create request error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}

export async function getAllRequests(req, res) {
  try {
    const requests = await prisma.request.findMany({
      include: {
        user: true,
        partner: true,
        serviceType: true,
        location: true,
      },
    });

    return res.json(requests);
  } catch (error) {
    console.error("Get all requests error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}

export async function getRequestById(req, res) {
  const { id } = req.params;

  try {
    const request = await prisma.request.findUnique({
      where: { id },
      include: {
        user: true,
        partner: true,
        serviceType: true,
        location: true,
      },
    });

    if (!request) {
      return res.status(404).json({ error: "Request not found" });
    }

    return res.json(request);
  } catch (error) {
    console.error("Get request by ID error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}

export async function getRequestsByUserId(req, res) {
  const { userId } = getRequestsByUserSchema.parse(req.params);

  try {
    const requests = await prisma.request.findMany({
      where: { userId },
      include: {
        partner: true,
        serviceType: true,
        location: true,
      },
    });

    return res.json(requests);
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: error.errors });
    }

    console.error("Get requests by user error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}

export async function getRequestsByPartnerId(req, res) {
  const { partnerId } = getRequestsByPartnerSchema.parse(req.params);

  try {
    const requests = await prisma.request.findMany({
      where: { partnerId },
      include: {
        user: true,
        serviceType: true,
        location: true,
      },
    });

    return res.json(requests);
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: error.errors });
    }

    console.error("Get requests by partner error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}

export async function updateRequestStatus(req, res) {
  const { id } = req.params;

  try {
    const { status, partnerId } = updateRequestStatusSchema.parse(req.body);

    const updatedRequest = await prisma.request.update({
      where: { id },
      data: {
        status,
        ...(partnerId && { partnerId }),
      },
    });

    return res.json({
      message: `Request ${status.toLowerCase()}`,
      request: updatedRequest,
    });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: error.errors });
    }

    console.error("Update request status error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}

export async function cancelRequest(req, res) {
  const { id } = req.params;

  try {
    const updatedRequest = await prisma.request.update({
      where: { id },
      data: { status: "CANCELLED" },
    });

    return res.json({
      message: "Request cancelled",
      request: updatedRequest,
    });
  } catch (error) {
    console.error("Cancel request error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}

export async function completeRequest(req, res) {
  const { id } = req.params;

  try {
    const updatedRequest = await prisma.request.update({
      where: { id },
      data: { status: "COMPLETED" },
    });

    return res.json({
      message: "Request completed",
      request: updatedRequest,
    });
  } catch (error) {
    console.error("Complete request error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}

export async function getRequestsByServiceType(req, res) {
  const { serviceTypeId } = getRequestsByServiceTypeSchema.parse(req.query);

  try {
    const requests = await prisma.request.findMany({
      where: { serviceTypeId },
      include: {
        user: true,
        partner: true,
        serviceType: true,
        location: true,
      },
    });

    return res.json(requests);
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: error.errors });
    }

    console.error("Get requests by service type error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}

export async function getNearbyActiveRequests(req, res) {
  try {
    const { latitude, longitude, radiusKm } = getNearbyRequestsSchema.parse(
      req.query
    );

    const minLat = latitude - radiusKm / 111;
    const maxLat = latitude + radiusKm / 111;
    const minLng =
      longitude - radiusKm / (111 * Math.cos((latitude * Math.PI) / 180));
    const maxLng =
      longitude + radiusKm / (111 * Math.cos((latitude * Math.PI) / 180));

    const requests = await prisma.request.findMany({
      where: {
        location: {
          latitude: { gte: minLat, lte: maxLat },
          longitude: { gte: minLng, lte: maxLng },
        },
        status: "PENDING",
      },
      include: {
        user: true,
        serviceType: true,
        location: true,
      },
    });

    return res.json(requests);
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: error.errors });
    }

    console.error("Get nearby requests error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}
