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
  deleteOrder,
  getDashboardStats,
  getRevenueChartData
} from "../controller/adminController.js";

import { getSettings, updateSettings } from "../controller/settingsController.js";

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

// --- DASHBOARD ROUTE ---
router.get("/dashboard-stats", getDashboardStats);
router.get("/revenue-chart", getRevenueChartData);

// --- SETTINGS ROUTES ---
router.get("/settings", getSettings);
router.put("/settings", updateSettings);

export default router;