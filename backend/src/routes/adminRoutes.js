import express from "express";
import { 
  getPendingSellers, 
  approveSeller, 
  rejectSeller,
  getAllProducts,
  deleteProduct,
  updateModelStatus,
  // New Order Imports
  getAllOrders,
  updateOrderStatus,
  updatePaymentStatus,
  deleteOrder
} from "../controllers/adminController.js";

const router = express.Router();

// --- SELLER VERIFICATION ROUTES ---
router.get("/sellers/pending", getPendingSellers);
router.put("/sellers/:id/approve", approveSeller);
router.delete("/sellers/:id/reject", rejectSeller);

// --- PRODUCT & AR MODEL ROUTES ---
router.get("/products", getAllProducts);
router.delete("/products/:id", deleteProduct);
router.put("/products/:id/model-status", updateModelStatus); 

// --- ORDER MANAGEMENT ROUTES ---
router.get("/orders", getAllOrders);
router.delete("/orders/:id", deleteOrder);
router.put("/orders/:id/status", updateOrderStatus);      // Requires { "status": "shipped" }
router.put("/orders/:id/payment", updatePaymentStatus);   // Requires { "paymentStatus": "paid" }

export default router;