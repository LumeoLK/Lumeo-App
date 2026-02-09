import express from "express";
import { addReview, getProductReviews } from "../controllers/review.controller.js";
import { verifyToken } from "../middleware/auth.middleware.js";

const router = express.Router();

// POST /api/reviews/add
router.post("/add", verifyToken, addReview);

// GET /api/reviews/:productId
router.get("/:productId", getProductReviews);

export default router;