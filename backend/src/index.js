import "./lib/env.js";
import express from "express";
import connectDB from "./config.js";
import cookieParser from "cookie-parser";
import cors from "cors";
import http from "http";

import adminRoutes from "./routes/adminRoutes.js";


import { Server } from "socket.io";
import setupSocket from "./socket/socketHandler.js";
const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(cookieParser());

app.use("/api/admin", adminRoutes);

import authRouter from "./routes/auth.js";
import sellerRoutes from "./routes/sellerRoutes.js";
import productRoutes from "./routes/productRoutes.js";
import customRequestRoutes from "./routes/customreqRoutes.js";
import cartRoutes from "./routes/cartRoutes.js";
import orderRoutes from "./routes/orderRoutes.js";
import reviewRoutes from "./routes/reviewRoutes.js";
import chatRoutes from "./routes/chatRoutes.js";
import webhookRoutes from "./routes/webhookRoutes.js";
import blueprintRoutes from "./routes/blueprint-to-3dRoutes.js";

app.use(cookieParser());
app.use(express.json()); //middleware

app.use(cors());
app.use(cookieParser());

app.use(express.json({ limit: "50mb" }));
app.use(express.urlencoded({ limit: "50mb", extended: true }));


app.use(express.static("public"));

/* ---------- Routes ---------- */

app.use("/api/auth", authRouter);
app.use("/api/seller", sellerRoutes);
app.use("/api/products", productRoutes);
app.use("/api/requests", customRequestRoutes);
app.use("/api/cart", cartRoutes);
app.use("/api/orders", orderRoutes);
app.use("/api/reviews", reviewRoutes);
app.use("/api/chat", chatRoutes);
app.use("/api/webhooks", webhookRoutes);
app.get("/api/health", (req, res) => {
  return res.status(200).json({ status: "ok" });
});
// Create HTTP server for Socket.io
const server = http.createServer(app);

// Attach Socket.io to the HTTP server
const io = new Server(server, {
  cors: {
    origin: ["http://localhost:8080"],
  },
});

// Socket.io
setupSocket(io);

try {
  connectDB();
  app.get("/", (req, res) => {
    res.send("Welcome to the Lumeo backend API 🚀");
  });
  app.on("error", (err) => {
    console.error("Error in app:", err);
  });

  server.listen(PORT, () => {
    console.log(`Connected to port ${PORT}`);
  });
} catch (error) {
  console.error("Error starting server:", error);
}

app.get("/", (req, res) => {
  res.send("Welcome to the Lumeo backend API");
});



