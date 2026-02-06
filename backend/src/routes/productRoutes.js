import express from "express";
import { createProduct, getAllProducts } from "../controller/product.controller.js";
import { verifyToken, verifySeller } from "../middleware/auth.js";
import upload from "../lib/cloudinary.js";

const router = express.Router();

router.post(
  "/create", 
  verifyToken, 
  verifySeller, 
  upload.array("images", 5), 
  createProduct
);


router.get("/", getAllProducts);

export default router;