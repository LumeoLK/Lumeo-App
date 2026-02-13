import upload from "../lib/cloudinary.js"; 
import { becomeSeller } from "../controller/sellerController.js";
import express from "express";
import { JWT } from "google-auth-library";
const router = express.Router();

router.post(
  "/become-seller", 
  verifyToken, 
  upload.fields([
    { name: 'logo', maxCount: 1 }, 
    { name: 'NICfront', maxCount: 1 },
    { name: 'NICback', maxCount: 1 }
  ]), 
  becomeSeller
);

export default router;