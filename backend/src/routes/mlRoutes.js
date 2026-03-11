import express from "express";
import Product from "../models/Product.js"; 

const router = express.Router();

router.get("/products", async (req, res) => {
  try {

    // Only return in-stock products
    const filter = { stock: { $gt: 0 } };

    const products = await Product.find(filter).select(
      "title description price category images dimensions dominantColor averageRating imageEmbedding model3D"
    );

    res.status(200).json({
      success: true,
      total: products.length,
      products,
    });
  } catch (error) {
    console.error("ML internal route error:", error);
    res.status(500).json({ success: false, message: error.message });
  }
});

export default router;