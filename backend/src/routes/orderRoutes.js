import express from "express";
import { getMyOrders, getSellerOrders, updateOrderStatus } from "../controller/orderController.js";
import { verifyToken, verifySeller } from "../middleware/auth.js";

const router = express.Router();

// USER: See my purchases
router.get("/my-orders", verifyToken, getMyOrders);

// SELLER: See my sales
// Note: You might need to update your verifySeller middleware to attach `req.user.sellerId`
router.get("/seller-orders", verifyToken, verifySeller, getSellerOrders);

// SELLER: Update status (e.g., mark as Shipped)
router.put("/update-status", verifyToken, verifySeller, updateOrderStatus);

export default router;