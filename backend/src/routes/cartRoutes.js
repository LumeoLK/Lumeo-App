import express from "express";
import {
  getCart,
  addToCart,
  removeFromCart,
} from "../controller/cartController.js";
import { verifyToken } from "../middleware/auth.js";

const router = express.Router();

router.get("/", verifyToken, getCart);
router.post("/add", verifyToken, addToCart);
router.delete("/remove", verifyToken, removeFromCart);
router.delete("/remove/:productId", verifyToken, removeFromCart);

export default router;
