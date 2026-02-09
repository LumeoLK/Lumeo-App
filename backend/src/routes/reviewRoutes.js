import express from "express";
import { addReview, getProductReviews } from "../controller/reviewController.js";
import { verifyToken } from "../middleware/auth.js";

const router = express.Router();

// POST /api/reviews/add
router.post("/add", verifyToken, addReview);

// GET /api/reviews/:productId
router.get("/:productId", getProductReviews);

export default router;