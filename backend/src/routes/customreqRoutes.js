import { createRequest, getOpenRequests, placeBid, getBidsByRequest, getMyRequests } from "../controller/bidController.js";
import { verifyToken, verifySeller } from "../middleware/auth.js";
import express from "express";
import upload from "../lib/cloudinary.js";

const router = express.Router();

router.post(
    "/create",
    verifyToken,
    upload.array("images", 3),
    createRequest
);

router.get("/feed", verifyToken, verifySeller, getOpenRequests);
router.get("/my-requests", verifyToken, getMyRequests);

router.post("/bid", verifyToken, verifySeller, upload.array("images", 3), placeBid);

router.post("/getbids", verifyToken, getBidsByRequest);

router.get("/test", (req, res) => res.json({ msg: "Requests router is working!" }));

export default router;
