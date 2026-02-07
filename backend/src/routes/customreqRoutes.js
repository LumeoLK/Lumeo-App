import express from "express";
import { createRequest, getOpenRequests, placeBid } from "../controllers/customRequest.controller.js";
import { verifyToken, verifySeller } from "../middleware/auth.middleware.js";
import upload from "../middleware/upload.middleware.js";

const router = express.Router();

// USER Routes
router.post(
    "/create", 
    verifyToken, 
    upload.array("images", 3), // Allow up to 3 reference images
    createRequest
);

// SELLER Routes
// 1. Get Feed of requests
router.get("/feed", verifyToken, verifySeller, getOpenRequests);

// 2. Place a Bid
router.post("/bid", verifyToken, verifySeller, placeBid);

export default router;