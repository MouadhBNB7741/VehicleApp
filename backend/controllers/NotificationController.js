import prisma from "../services/prisma.js";
import {
  sendNotificationToUserSchema,
  sendNotificationToPartnerSchema,
} from "../validators/Notifications.js";
import * as z from "zod";

export async function sendNotificationToUser(req, res) {
  try {
    const data = sendNotificationToUserSchema.parse(req.body);

    const notification = await prisma.notification.create({
      data: {
        ...data,
        read: false,
      },
    });

    return res.status(201).json(notification);
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: error.errors });
    }

    console.error("Send notification to user error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}

export async function sendNotificationToPartner(req, res) {
  try {
    const data = sendNotificationToPartnerSchema.parse(req.body);

    const notification = await prisma.notification.create({
      data: {
        ...data,
        read: false,
      },
    });

    return res.status(201).json(notification);
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: error.errors });
    }

    console.error("Send notification to partner error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}

export async function markNotificationAsRead(req, res) {
  const { id } = req.params;

  try {
    const updated = await prisma.notification.update({
      where: { id },
      data: { read: true },
    });

    return res.json({
      message: "Notification marked as read",
      notification: updated,
    });
  } catch (error) {
    if (error.code === "P2025") {
      return res.status(404).json({ error: "Notification not found" });
    }

    console.error("Mark notification as read error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}

export async function getAllNotificationsForUser(req, res) {
  const { userId } = req.params;

  try {
    const notifications = await prisma.notification.findMany({
      where: { userId },
      include: {
        user: true,
      },
    });

    return res.json(notifications);
  } catch (error) {
    console.error("Get notifications by user error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}

export async function getAllNotificationsForPartner(req, res) {
  const { partnerId } = req.params;

  try {
    const notifications = await prisma.notification.findMany({
      where: { partnerId },
      include: {
        partner: true,
      },
    });

    return res.json(notifications);
  } catch (error) {
    console.error("Get notifications by partner error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}
