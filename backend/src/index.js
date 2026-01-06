import express from "express";
import mongoose from "mongoose";
import dotenv from "dotenv";
import authRouter from "./routes/auth.js";
dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json()); //middleware
app.use(express.static("public"));
app.use(authRouter);
mongoose
  .connect(process.env.MONGODB_URL)
  .then(() => console.log("DB Connect successfully"))
  .catch((e) => {
    console.log(e);
  });
app.listen(PORT, () => {
  console.log(`Connected to port ${PORT}`);
});
