import express from "express";
import dotenv from "dotenv";
import authRouter from "./routes/auth.js";
import connectDB from "./config.js";
import cookieParser from "cookie-parser";
import cors from "cors";

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json()); //middleware
app.use(express.static("public"));
app.use(authRouter);
app.use(cookieParser());

try {
  connectDB();
  app.get("/", (req, res) => {
  res.send("Welcome to the Parking Lot API 🚀");
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

