import prisma from "../services/prisma.js";
import {
  createTransactionSchema,
  updateTransactionStatusSchema,
} from "../validators/Transaction.js";
import * as z from "zod";

function calculateTax(amount) {
  const TAX_RATE = 0.15;
  return parseFloat((amount * TAX_RATE).toFixed(2));
}

export async function createTransaction(req, res) {
  try {
    const data = createTransactionSchema.parse(req.body);

    const request = await prisma.request.findUnique({
      where: { id: data.requestId },
      include: { partner: true, user: true },
    });

    if (!request || request.partnerId !== data.partnerId) {
      return res.status(400).json({ error: "Invalid request or partner" });
    }

    const taxAmount = calculateTax(data.amount);
    const totalAmount = data.amount + taxAmount;

    const transaction = await prisma.transaction.create({
      data: {
        ...data,
        taxAmount,
        totalAmount,
        paymentStatus: "UNPAID",
      },
    });

    return res.status(201).json(transaction);
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: error.errors });
    }

    console.error("Create transaction error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}

export async function getTransactionByRequestId(req, res) {
  const { requestId } = req.params;

  try {
    const transaction = await prisma.transaction.findFirst({
      where: { requestId },
      include: {
        request: true,
        partner: true,
      },
    });

    if (!transaction) {
      return res.status(404).json({ error: "Transaction not found" });
    }

    return res.json(transaction);
  } catch (error) {
    console.error("Get transaction by request error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}

export async function getAllTransactions(req, res) {
  try {
    const transactions = await prisma.transaction.findMany({
      include: {
        request: true,
        partner: true,
        user: true,
      },
    });

    return res.json(transactions);
  } catch (error) {
    console.error("Get all transactions error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}

export async function getTransactionsByUserId(req, res) {
  const { userId } = req.params;

  try {
    const transactions = await prisma.transaction.findMany({
      where: { request: { userId } },
      include: {
        request: true,
        partner: true,
      },
    });

    return res.json(transactions);
  } catch (error) {
    console.error("Get transactions by user error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}

export async function getTransactionsByPartnerId(req, res) {
  const { partnerId } = req.params;

  try {
    const transactions = await prisma.transaction.findMany({
      where: { partnerId },
      include: {
        request: true,
        partner: true,
      },
    });

    return res.json(transactions);
  } catch (error) {
    console.error("Get transactions by partner error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}

export async function updateTransactionStatus(req, res) {
  const { id } = req.params;

  try {
    const { paymentStatus } = updateTransactionStatusSchema.parse(req.body);

    const updated = await prisma.transaction.update({
      where: { id },
      data: { paymentStatus },
    });

    return res.json({
      message: `Transaction ${paymentStatus.toLowerCase()}`,
      transaction: updated,
    });
  } catch (error) {
    if (error.code === "P2025") {
      return res.status(404).json({ error: "Transaction not found" });
    }

    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: error.errors });
    }

    console.error("Update transaction status error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}

export async function calculateAndApplyTax(req, res) {
  const { id } = req.params;

  try {
    const transaction = await prisma.transaction.findUnique({
      where: { id },
    });

    if (!transaction) {
      return res.status(404).json({ error: "Transaction not found" });
    }

    const taxAmount = calculateTax(transaction.amount);
    const totalAmount = transaction.amount + taxAmount;

    const updated = await prisma.transaction.update({
      where: { id },
      data: {
        taxAmount,
        totalAmount,
      },
    });

    return res.json(updated);
  } catch (error) {
    console.error("Calculate tax error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}

export async function refundTransaction(req, res) {
  const { id } = req.params;

  try {
    const transaction = await prisma.transaction.findUnique({
      where: { id },
    });

    if (!transaction) {
      return res.status(404).json({ error: "Transaction not found" });
    }

    if (transaction.paymentStatus !== "PAID") {
      return res
        .status(400)
        .json({ error: "Only paid transactions can be refunded" });
    }

    const updated = await prisma.transaction.update({
      where: { id },
      data: {
        paymentStatus: "REFUNDED",
      },
    });

    return res.json({
      message: "Transaction has been refunded",
      transaction: updated,
    });
  } catch (error) {
    console.error("Refund transaction error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}
