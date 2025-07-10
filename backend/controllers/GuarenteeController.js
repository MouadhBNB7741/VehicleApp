import prisma from "../services/prisma.js";
import {
  issueGuaranteeSchema,
  requestCarVerificationSchema,
  verifyCarSchema,
} from "../validators/Guarantee.js";

export async function requestCarVerification(req, res) {
  try {
    const data = requestCarVerificationSchema.parse(req.body);

    const newVerification = await prisma.carVerification.create({
      data: {
        ...data,
        status: "PENDING",
      },
    });

    return res.status(201).json(newVerification);
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: error.errors });
    }

    console.error("Car verification request error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}

export async function getAllVerifications(req, res) {
  try {
    const verifications = await prisma.carVerification.findMany({
      include: {
        user: true,
        verifiedBy: true,
      },
    });

    return res.json(verifications);
  } catch (error) {
    console.error("Get all verifications error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}

export async function getVerificationById(req, res) {
  const { id } = req.params;

  try {
    const verification = await prisma.carVerification.findUnique({
      where: { id },
      include: {
        user: true,
        verifiedBy: true,
        guarantee: true,
      },
    });

    if (!verification) {
      return res.status(404).json({ error: "Verification not found" });
    }

    return res.json(verification);
  } catch (error) {
    console.error("Get verification by ID error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}

export async function verifyCar(req, res) {
  const { id } = req.params;

  try {
    const { adminId, status } = verifyCarSchema.parse(req.body);

    const updatedVerification = await prisma.carVerification.update({
      where: { id },
      data: {
        status,
        verifiedBy: {
          connect: { id: adminId },
        },
      },
    });

    return res.json({
      message: `Car ${status.toLowerCase()}`,
      verification: updatedVerification,
    });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: error.errors });
    }

    console.error("Verify car error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}

export async function issueGuarantee(req, res) {
  const { verificationId } = req.params;

  try {
    const { validUntil, terms } = issueGuaranteeSchema.parse(req.body);

    const guarantee = await prisma.guarantee.create({
      data: {
        verificationId,
        validUntil,
        terms,
      },
    });

    const updatedVerification = await prisma.carVerification.update({
      where: { id: verificationId },
      data: {
        guaranteeId: guarantee.id,
        status: "VERIFIED",
      },
    });

    return res.json({
      message: "Guarantee issued",
      guarantee,
      verification: updatedVerification,
    });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: error.errors });
    }

    console.error("Issue guarantee error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}

export async function getGuaranteeByVerificationId(req, res) {
  const { verificationId } = req.params;

  try {
    const guarantee = await prisma.guarantee.findUnique({
      where: { verificationId },
      include: {
        verification: true,
      },
    });

    if (!guarantee) {
      return res.status(404).json({ error: "Guarantee not found" });
    }

    return res.json(guarantee);
  } catch (error) {
    console.error("Get guarantee by verification error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}

export async function checkGuaranteeValidity(req, res) {
  const { verificationId } = req.params;

  try {
    const guarantee = await prisma.guarantee.findUnique({
      where: { verificationId },
    });

    if (!guarantee) {
      return res.json({
        valid: false,
        message: "No guarantee issued for this verification",
      });
    }

    const now = new Date();
    const isValid = guarantee.validUntil > now;

    return res.json({
      valid: isValid,
      validUntil: guarantee.validUntil,
      terms: guarantee.terms,
    });
  } catch (error) {
    console.error("Check guarantee validity error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}

export async function getVerificationsByUserId(req, res) {
  const { userId } = req.params;

  try {
    const verifications = await prisma.carVerification.findMany({
      where: { userId },
      include: {
        guarantee: true,
        verifiedBy: true,
      },
    });

    return res.json(verifications);
  } catch (error) {
    console.error("Get verifications by user error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}
