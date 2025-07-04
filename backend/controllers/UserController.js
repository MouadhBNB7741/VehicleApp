import { hash, compare } from "bcryptjs";
import prisma from "../services/prisma.js";
import {
  registerUserSchema,
  getUserByIdSchema,
  loginUserSchema,
  searchUsersSchema,
  updateUserSchema,
} from "../validators/User.js";
import * as zod from "zod";
import jwt from "jsonwebtoken";

export async function registerUser(req, res) {
  try {
    const { email, fullName, password, phoneNumber } = registerUserSchema.parse(
      req.body
    );

    if (!email && !phoneNumber) {
      res.status.json({
        error: "Must at least have an email or a phone number",
      });
    }

    const hashedPassword = await hash(password, 10);

    const newUser = await prisma.user.create({
      data: {
        email,
        fullName,
        passwordHash: hashedPassword,
        role: "USER",
        phoneNumber,
      },
    });

    res.status(201).json({
      message: "User created successfully",
      user: newUser,
    });
  } catch (error) {
    if (error instanceof zod.ZodError) {
      return res.status(400).json({ error: error.errors });
    }

    console.error("Registration error:", error);

    return res.status(500).json({
      message: "Sorry, something went wrong. Please try again later.",
    });
  }
}

export async function login(req, res) {
  try {
    const { email, phoneNumber, password } = loginUserSchema.parse(req.body);

    console.log(await hash(password, 10));

    const user = await prisma.user.findFirst({
      where: {
        OR: [{ email }, { phoneNumber }],
      },
    });

    if (!user) {
      return res.status(400).json({ error: "Invalid credentials" });
    }

    const isPasswordValid = await compare(password, user.passwordHash);
    if (!isPasswordValid) {
      return res.status(400).json({ error: "Invalid credentials" });
    }

    const token = jwt.sign(
      {
        userId: user.id,
        role: user.role,
      },
      process.env.JWT_SECRET,
      { expiresIn: "1d" }
    );

    return res.json({
      message: "Login successful",
      token,
      user: {
        id: user.id,
        fullName: user.fullName,
        email: user.email,
        role: user.role,
        phoneNumber: user.phoneNumber,
      },
    });
  } catch (error) {
    if (error instanceof zod.ZodError) {
      return res.status(400).json({ error: error.errors });
    }

    console.error("Registration error:", error);

    return res.status(500).json({
      message: "Sorry, something went wrong. Please try again later.",
    });
  }
}

export async function logout(req, res) {
  return res.json({ message: "Logged out successfully" });
}

export async function getCurrentUserProfile(req, res) {
  const userId = req.user.id;

  try {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        fullName: true,
        email: true,
        phoneNumber: true,
        role: true,
        createdAt: true,
        updatedAt: true,
      },
    });

    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }

    return res.json({ user });
  } catch (error) {
    console.error("Get current user error:", error);
    return res.status(500).json({
      message: "Something went wrong. Please try again later.",
    });
  }
}

export async function updateUserProfile(req, res) {
  const userId = req.user.id;

  try {
    const updateData = updateUserSchema.parse(req.body);

    const updatedUser = await prisma.user.update({
      where: { id: userId },
      data: updateData,
      select: {
        id: true,
        fullName: true,
        email: true,
        phoneNumber: true,
        role: true,
        updatedAt: true,
      },
    });

    return res.json({ user: updatedUser });
  } catch (error) {
    if (error instanceof zod.ZodError) {
      return res.status(400).json({ error: error.errors });
    }

    if (error.code === "P2025") {
      return res.status(404).json({ error: "User not found" });
    }

    console.error("Update user error:", error);
    return res.status(500).json({
      message: "Something went wrong. Please try again later.",
    });
  }
}

export async function getUserById(req, res) {
  try {
    const { id } = getUserByIdSchema.parse(req.params);
    const user = await prisma.user.findUnique({
      where: { id },
      select: {
        id: true,
        fullName: true,
        email: true,
        phoneNumber: true,
        role: true,
        createdAt: true,
      },
    });

    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }

    return res.json({ user });
  } catch (error) {
    console.error("Get user by ID error:", error);
    return res.status(500).json({
      message: "Something went wrong. Please try again later.",
    });
  }
}

export async function searchUsers(req, res) {
  try {
    const query = searchUsersSchema.parse(req.query);

    const { search = "", role, limit = 10, page = 1 } = query;
    const skip = (page - 1) * limit;

    const users = await prisma.user.findMany({
      where: {
        AND: [
          {
            OR: [
              { fullName: { contains: search, mode: "insensitive" } },
              { email: { contains: search, mode: "insensitive" } },
            ],
          },
          role ? { role } : {},
        ],
      },
      skip,
      take: limit,
      select: {
        id: true,
        fullName: true,
        email: true,
        phoneNumber: true,
        role: true,
        createdAt: true,
      },
    });

    return res.json({ users });
  } catch (error) {
    console.error("Search users error:", error);
    return res.status(500).json({
      message: "Something went wrong. Please try again later.",
    });
  }
}

export async function adminCreateUser(req, res) {
  try {
    const { email, fullName, password, phoneNumber, role } =
      registerUserSchema.parse(req.body);

    const hashedPassword = await hash(password, 10);

    const newUser = await prisma.user.create({
      data: {
        email,
        fullName,
        passwordHash: hashedPassword,
        role,
        phoneNumber,
      },
    });

    res.status(201).json({
      message: "User created successfully",
      user: newUser,
    });
  } catch (error) {
    if (error instanceof zod.ZodError) {
      return res.status(400).json({ error: error.errors });
    }

    console.error("Registration error:", error);

    return res.status(500).json({
      message: "Sorry, something went wrong. Please try again later.",
    });
  }
}
