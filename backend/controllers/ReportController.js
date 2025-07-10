import prisma from "../services/prisma.js";
import {
  createReportSchema,
  getReportsByPartnerSchema,
  getReportsByUserSchema,
  resolveReportSchema,
} from "../validators/Report.js";
import * as z from "zod";

export async function submitReportOnPartner(req, res) {
  try {
    const data = createReportSchema.parse(req.body);

    const newReport = await prisma.report.create({
      data: {
        ...data,
        resolved: false,
      },
    });

    return res.status(201).json(newReport);
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: error.errors });
    }

    console.error("Submit report error:", error);
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

export async function getReportById(req, res) {
  const { id } = req.params;

  try {
    const report = await prisma.report.findUnique({
      where: { id },
      include: {
        reporter: true,
        partner: true,
      },
    });

    if (!report) {
      return res.status(404).json({ error: "Report not found" });
    }

    return res.json(report);
  } catch (error) {
    console.error("Get report by ID error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}

export async function resolveReport(req, res) {
  const { id } = req.params;

  try {
    const { adminNotes } = resolveReportSchema.parse(req.body);

    const updatedReport = await prisma.report.update({
      where: { id },
      data: {
        resolved: true,
        adminNotes,
        updatedAt: new Date(),
      },
    });

    return res.json({
      message: "Report resolved",
      report: updatedReport,
    });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: error.errors });
    }

    console.error("Resolve report error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}

export async function getReportsByUserId(req, res) {
  const { userId } = getReportsByUserSchema.parse(req.params);

  try {
    const reports = await prisma.report.findMany({
      where: { reporterId: userId },
      include: {
        partner: true,
        reporter: true,
      },
    });

    return res.json(reports);
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: error.errors });
    }

    console.error("Get reports by user error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}

export async function getReportsByPartnerId(req, res) {
  const { partnerId } = getReportsByPartnerSchema.parse(req.params);

  try {
    const reports = await prisma.report.findMany({
      where: { partnerId },
      include: {
        reporter: true,
        partner: true,
      },
    });

    return res.json(reports);
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: error.errors });
    }

    console.error("Get reports by partner error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}
