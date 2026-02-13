import express from "express";
import { getUserOrders, getSellerOrders, updateOrderStatus } from "../controllers/order.controller.js";
import { verifyToken, verifySeller } from "../middleware/auth.middleware.js";

const router = express.Router();

// USER: See my purchases
router.get("/my-orders", verifyToken, getUserOrders);

// SELLER: See my sales
// Note: You might need to update your verifySeller middleware to attach `req.user.sellerId`
router.get("/seller-orders", verifyToken, verifySeller, getSellerOrders);

// SELLER: Update status (e.g., mark as Shipped)
router.put("/update-status", verifyToken, verifySeller, updateOrderStatus);

export default router;