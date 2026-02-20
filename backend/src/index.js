import express from "express";
import dotenv from "dotenv";

import connectDB from "./config.js";
import cookieParser from "cookie-parser";
import cors from "cors";

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

import authRouter from "./routes/auth.js";
import sellerRoutes from "./routes/sellerRoutes.js";
import productRoutes from "./routes/productRoutes.js";
import customRequestRoutes from "./routes/customreqRoutes.js";
import cartRoutes from "./routes/cartRoutes.js";
import orderRoutes from "./routes/orderRoutes.js";
import reviewRoutes from "./routes/reviewRoutes.js";

app.use(express.json()); //middleware
app.use(express.static("public"));

app.use("/api/auth", authRouter);
app.use("/api/seller", sellerRoutes);
app.use("/api/products", productRoutes);
app.use("/api/requests", customRequestRoutes); 
app.use("/api/cart", cartRoutes);
app.use("/api/orders", orderRoutes);
app.use("/api/reviews", reviewRoutes);

app.use(cookieParser());

try {
  connectDB();
  app.get("/", (req, res) => {
  res.send("Welcome to the Lumeo backend API 🚀");
});
    app.on('error', err => {
      console.error("Error in app:", err);
    });

  app.listen(PORT, () => {
    console.log(`Connected to port ${PORT}`);
  });
} catch (error) {
  console.error("Error starting server:", error); 
}

