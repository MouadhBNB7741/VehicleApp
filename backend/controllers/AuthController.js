import prisma from "../services/prisma.js";
import jwt from "jsonwebtoken";
import { hash, compare } from "bcryptjs";
import { sendMessage } from "../services/nodemailer";
import {
  verifyEmailSchema,
  resetPasswordSchema,
  changePasswordSchema,
} from "../validators/Auth.js";
import * as z from "zod";

export async function sendEmailVerification(req, res) {
  try {
    const { userId } = verifyEmailSchema.parse(req.body);

    const user = await prisma.user.findUnique({ where: { id: userId } });

    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }

    if (user.emailVerified) {
      return res.json({ message: "Email already verified" });
    }

    const token = jwt.sign(
      { id: user.id, purpose: "verify_email" },
      process.env.JWT_SECRET,
      {
        expiresIn: "1d",
      }
    );

    const verifyLink = `${token}`; //TODO need to be changed

    await sendMessage({
      to: user.email,
      subject: "Verify Your Email",
      html: `<p>Click <a href="${verifyLink}">here</a> to verify your email.</p>`,
    });

    return res.json({ message: "Verification email sent" });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: error.errors });
    }

    console.error("Send email verification error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}

export async function verifyEmail(req, res) {
  const { token } = req.params;

  try {
    const decoded = jwt.verify(token, JWT_SECRET);

    if (decoded.purpose !== "verify_email") {
      return res.status(400).json({ error: "Invalid token purpose" });
    }

    const user = await prisma.user.update({
      where: { id: decoded.id },
      data: { emailVerified: true },
    });

    return res.json({ message: "Email verified successfully", user });
  } catch (error) {
    return res.status(400).json({ error: "Invalid or expired token" });
  }
}

export async function sendPasswordResetEmail(req, res) {
  const { email } = req.body;

  try {
    const user = await prisma.user.findUnique({ where: { email } });

    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }

    const token = jwt.sign(
      { id: user.id, purpose: "reset_password" },
      JWT_SECRET,
      { expiresIn: "1h" }
    );

    const resetLink = `${token}`; //TODO change url

    await sendMessage({
      to: email,
      subject: "Reset Your Password",
      html: `<p>Click <a href="${resetLink}">here</a> to reset your password.</p>`,
    });

    return res.json({ message: "Password reset email sent" });
  } catch (error) {
    console.error("Send password reset email error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}

export async function resetPassword(req, res) {
  const { token } = req.params;

  try {
    const { newPassword } = resetPasswordSchema.parse(req.body);

    const decoded = jwt.verify(token, JWT_SECRET);

    if (decoded.purpose !== "reset_password") {
      return res.status(400).json({ error: "Invalid token purpose" });
    }

    const hashedPassword = await hash(newPassword, 10);

    const updatedUser = await prisma.user.update({
      where: { id: decoded.id },
      data: { passwordHash: hashedPassword },
    });

    return res.json({
      message: "Password reset successfully",
      user: updatedUser,
    });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: error.errors });
    }

    console.error("Reset password error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}

export async function changePassword(req, res) {
  const userId = req.user.id;

  try {
    const { oldPassword, newPassword } = changePasswordSchema.parse(req.body);

    const user = await prisma.user.findUnique({ where: { id: userId } });

    const isPasswordValid = await compare(oldPassword, user.passwordHash);

    if (!isPasswordValid) {
      return res.status(400).json({ error: "Old password is incorrect" });
    }

    const hashedPassword = await hash(newPassword, 10);

    const updatedUser = await prisma.user.update({
      where: { id: userId },
      data: { passwordHash: hashedPassword },
    });

    return res.json({ message: "Password changed", user: updatedUser });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: error.errors });
    }

    console.error("Change password error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}
