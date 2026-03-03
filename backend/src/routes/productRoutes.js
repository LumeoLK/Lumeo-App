import express from "express";
import { verifyToken, verifySeller } from "../middleware/auth.js";
import upload from "../lib/cloudinary.js";
import {
  getAllProducts,
  searchProducts,
} from "../controller/sellerController.js";
import { createProduct } from "../controller/productController.js";


import {
  handleMeshyWebhook,
  updateStatus,
} from "../controller/productController.js";

const router = express.Router();

router.post(
  "/create",
  verifyToken,
  verifySeller,
  upload.array("images", 4),
  createProduct,
);

//webhooks
router.post("/webhook/meshy-success", handleMeshyWebhook);

router.get("/", getAllProducts);
router.get("/search", searchProducts);

router.post("/webhook/meshy-success/:productId", updateStatus);
export default router;
