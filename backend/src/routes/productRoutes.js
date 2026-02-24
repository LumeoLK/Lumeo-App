import express from "express";
import { verifyToken, verifySeller } from "../middleware/auth.js";
import upload from "../lib/cloudinary.js";
import {
  getAllProducts,
  searchProducts,
} from "../controller/sellerController.js";
const router = express.Router();
import {createProduct} from "../controller/productController.js";
import { generate3DModel } from "../controller/productController.js";

router.post(
  "/create",
  verifyToken,
  verifySeller,
  upload.array("images", 5),
  createProduct,
);
router.post("/generate3d", generate3DModel);


router.get("/", getAllProducts);
router.get("/search", searchProducts);

export default router;
