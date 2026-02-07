import express from "express";
import { createRequest, getOpenRequests, placeBid } from "../controllers/customRequest.controller.js";
import { verifyToken, verifySeller } from "../middleware/auth.middleware.js";
import upload from "../middleware/upload.middleware.js";

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