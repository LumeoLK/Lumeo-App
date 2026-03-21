import express from "express";
import { 
  getPendingSellers, 
  approveSeller, 
  rejectSeller,
  getAllProducts,
  deleteProduct,
  updateModelStatus
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

export default router;