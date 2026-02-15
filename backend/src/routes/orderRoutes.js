import express from "express";
import { getUserOrders, getSellerOrders, updateOrderStatus,createOrder ,placeOrder} from "../controller/orderController.js";
import { verifyToken, verifySeller } from "../middleware/auth.js";

const router = express.Router();


router.get("/my-orders", verifyToken, getUserOrders);

router.get("/seller-orders", verifyToken, verifySeller, getSellerOrders);

router.put("/update-status", verifyToken, verifySeller, updateOrderStatus);

router.post("/create", verifyToken, placeOrder);

export default router;