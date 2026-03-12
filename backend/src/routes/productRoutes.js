import express from "express";
import { verifyToken, verifySeller } from "../middleware/auth.js";
import upload from "../lib/cloudinary.js";
import {
  createProduct,
  getAllProducts,
  getProductById,
  searchProducts,
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
router.get("/:id", getProductById);

export default router;
