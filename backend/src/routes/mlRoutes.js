import express from "express";
import { getProductsForML } from "../controller/productController.js";

const router = express.Router();

router.get("/products", getProductsForML);

export default router;
