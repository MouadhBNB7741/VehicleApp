import prisma from "../services/prisma.js";
import {
  approvePartnerSchema,
  declinePartnerSchema,
  banPartnerSchema,
  deleteEntitySchema,
} from "../validators/Admin.js";
import * as z from "zod";

export async function approvePartnerApplication(req, res) {
  try {
    const { applicationId } = approvePartnerSchema.parse(req.body);

    const updatedApp = await prisma.partnerApplication.update({
      where: { id: applicationId },
      data: { status: "APPROVED" },
    });

    return res.json({ message: "Partner approved", application: updatedApp });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: error.errors });
    }

    console.error("Approve partner error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}

export async function declinePartnerApplication(req, res) {
  try {
    const { applicationId, reason } = declinePartnerSchema.parse(req.body);

    const updatedApp = await prisma.partnerApplication.update({
      where: { id: applicationId },
      data: { status: "DECLINED", reviewedAt: new Date(), adminNotes: reason },
    });

    return res.json({ message: "Partner declined", application: updatedApp });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: error.errors });
    }

    console.error("Decline partner error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}

export async function banPartner(req, res) {
  try {
    const { partnerId, reason } = banPartnerSchema.parse(req.body);

    const bannedPartner = await prisma.partner.update({
      where: { id: partnerId },
      data: { isAvailable: false, adminNotes: reason },
    });

    return res.json({ message: "Partner banned", partner: bannedPartner });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: error.errors });
    }

    console.error("Ban partner error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}

export async function unbanPartner(req, res) {
  const { partnerId } = req.params;

  try {
    const unbannedPartner = await prisma.partner.update({
      where: { id: partnerId },
      data: { isAvailable: true, adminNotes: null },
    });

    return res.json({ message: "Partner unbanned", partner: unbannedPartner });
  } catch (error) {
    console.error("Unban partner error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}

export async function getAllReports(req, res) {
  try {
    const reports = await prisma.report.findMany({
      include: {
        reporter: true,
        partner: true,
      },
    });

    return res.json(reports);
  } catch (error) {
    console.error("Get all reports error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}

export async function resolveReport(req, res) {
  const { reportId } = req.params;

  try {
    const { resolutionNotes } = req.body;

    const resolvedReport = await prisma.report.update({
      where: { id: reportId },
      data: { resolved: true, adminNotes: resolutionNotes },
    });

    return res.json({ message: "Report resolved", report: resolvedReport });
  } catch (error) {
    console.error("Resolve report error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}

export async function deleteUserOrPartner(req, res) {
  try {
    const { id } = deleteEntitySchema.parse(req.params);
    const user = await prisma.user.findUnique({ where: { id } });
    if (user) {
      await prisma.user.delete({ where: { id } });
      return res.json({ message: "User deleted" });
    }

    const partner = await prisma.partner.findUnique({ where: { id } });
    if (partner) {
      await prisma.partner.delete({ where: { id } });
      return res.json({ message: "Partner deleted" });
    }

    return res.status(404).json({ error: "Entity not found" });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: error.errors });
    }

    console.error("Delete entity error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}
