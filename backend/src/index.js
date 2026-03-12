import "./lib/env.js";
import express from "express";
import connectDB from "./config.js";
import cookieParser from "cookie-parser";
import cors from "cors";

import authRouter from "./routes/auth.js";
import sellerRoutes from "./routes/sellerRoutes.js";
import productRoutes from "./routes/productRoutes.js";
import customRequestRoutes from "./routes/customreqRoutes.js";
import cartRoutes from "./routes/cartRoutes.js";
import orderRoutes from "./routes/orderRoutes.js";
import reviewRoutes from "./routes/reviewRoutes.js";
import webhookRoutes from "./routes/webhookRoutes.js";
import blueprintRoutes from "./routes/blueprint-to-3dRoutes.js";

const app = express();
const PORT = process.env.PORT || 3000;

/* ---------- Middleware ---------- */

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
app.use("/api/blueprint", blueprintRoutes);

app.use("/api", webhookRoutes);

/* ---------- Root ---------- */

app.get("/", (req, res) => {
  res.send("Welcome to the Lumeo backend API");
});

/* ---------- Start Server ---------- */

try {
  connectDB();

  app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
  });

} catch (error) {
  console.error("Error starting server:", error);
}