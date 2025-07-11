import prisma from "../services/prisma.js";
import {
  createServiceTypeSchema,
  updateServiceTypeSchema,
  getServiceByCategorySchema,
} from "../validators/Service.js";
import * as z from "zod";

export async function getAllServiceTypes(req, res) {
  try {
    const services = await prisma.serviceType.findMany();

    return res.json(services);
  } catch (error) {
    console.error("Get all services error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}

export async function getServicesByCategory(req, res) {
  try {
    const { category } = getServiceByCategorySchema.parse(req.params);
    const services = await prisma.serviceType.findMany({
      where: {
        category,
      },
    });

    return res.json(services);
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: error.errors });
    }

    console.error("Get services by category error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}

export async function addNewServiceType(req, res) {
  try {
    const data = createServiceTypeSchema.parse(req.body);

    const newService = await prisma.serviceType.create({
      data,
    });

    return res.status(201).json(newService);
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: error.errors });
    }

    console.error("Add service type error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}

export async function updateServiceType(req, res) {
  const { id } = req.params;

  try {
    const data = updateServiceTypeSchema.parse(req.body);

    const updatedService = await prisma.serviceType.update({
      where: { id },
      data,
    });

    return res.json({
      message: "Service type updated",
      service: updatedService,
    });
  } catch (error) {
    if (error.code === "P2025") {
      return res.status(404).json({ error: "Service type not found" });
    }

    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: error.errors });
    }

    console.error("Update service type error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}

export async function deleteServiceType(req, res) {
  const { id } = req.params;

  try {
    await prisma.serviceType.delete({
      where: { id },
    });

    return res.json({ message: "Service type deleted" });
  } catch (error) {
    if (error.code === "P2025") {
      return res.status(404).json({ error: "Service type not found" });
    }

    console.error("Delete service type error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}
