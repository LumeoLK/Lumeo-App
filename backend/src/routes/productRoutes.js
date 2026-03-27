import express from "express";
import { verifyToken, verifySeller } from "../middleware/auth.js";
import upload from "../lib/cloudinary.js";
import {
  createProduct,
  getAllProducts,
  getProductById,
  searchProducts,
  retry3dgeneration,
  getProductsForML,
  deleteProduct,
  getProductsBySeller,
} from "../controller/productController.js";

const router = express.Router();

router.post(
  "/create",
  verifyToken,
  verifySeller,
  upload.array("images", 4),
  createProduct,
);

router.get("/", getAllProducts);
router.get("/search", searchProducts);
router.post("/retry3d", retry3dgeneration);
router.get("/mlproducts", getProductsForML);
router.post("/delete", verifyToken, verifySeller, deleteProduct);
router.get("/seller/me", verifyToken, verifySeller, getProductsBySeller);
router.get("/:id", getProductById);
export default router;
