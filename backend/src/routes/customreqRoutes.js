import express from "express";
import { createRequest, getOpenRequests, placeBid } from "../controller/bidController.js";
import { verifyToken, verifySeller } from "../middleware/auth.js";
import upload from "../lib/cloudinary.js";

const router = express.Router();


router.post(
    "/create", 
    verifyToken, 
    upload.array("images", 3), 
    createRequest
);


router.get("/feed", verifyToken, verifySeller, getOpenRequests);


router.post("/bid", verifyToken, verifySeller,upload.array("images", 3), placeBid);

export default router;