import express from "express";
import cors from "cors";
import helmet from "helmet";
import morgan from "morgan";
import dotenv from "dotenv";
import { fileURLToPath } from "url";
import { dirname } from "path";
import { userRouter, partnerRouter } from "./routes/exporter.js";

dotenv.config();

const app = express();

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Middleware
app.use(express.json());
app.use(cors());
app.use(helmet());

//making the images acceptable
// app.use("/uploads", express.static(__dirname, "uploads"));

if (process.env.NODE_ENV !== "test") {
  app.use(morgan("dev"));
}

// Routes
app.use("/user", userRouter);
app.use("/partner", partnerRouter);

app.listen(8081, () => {
  console.log("Mouadh in the back says Hi!");
});

// Error Handler
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: "Something went wrong!" });
});
