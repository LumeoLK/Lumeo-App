import express from "express";
import { verifyToken, verifySeller } from "../middleware/auth.js";
import upload from "../lib/cloudinary.js";
import { createProduct, getAllProducts, searchProducts, getProductById } from "../controller/sellerController.js";
const router = express.Router();


router.post(
  "/create",
  verifyToken,
  verifySeller,
  upload.array("images", 5),
  createProduct,
);

router.get("/", getAllProducts);
router.get("/search", searchProducts);
router.get("/:id", getProductById);

export default router;
