import express from "express";
import { verifyToken, verifySeller } from "../middleware/auth.js";
import upload from "../lib/cloudinary.js";
import { searchProducts,getAllProducts } from "../controller/sellerController.js";
import { createProduct } from "../controller/productController.js";


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

export default router;
