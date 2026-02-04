import express from "express";
import mongoose from "mongoose";
import dotenv from "dotenv";
import authRouter from "./routes/auth.js";
import connectDB from "./config.js";
import testConnection from "./test_db.js";
dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json()); //middleware
app.use(express.static("public"));
app.use(authRouter);


try {
  connectDB();
    app.on('error', err => {
      console.error("Error in app:", err);
    });

  app.listen(PORT, () => {
    console.log(`Connected to port ${PORT}`);
  });
} catch (error) {
  console.error("Error starting server:", error); 
}

