import upload from "../lib/cloudinary.js";
import {
  becomeSeller,
  getSellerActiveListings,
  getSellerDashboard,
  getSellerPerformance,
  getSellerProfile,
  getSellerRecentOrders,
  getSellerSummary,
} from "../controller/sellerController.js";
import express from "express";
import { verifySeller, verifyToken } from "../middleware/auth.js";
const router = express.Router();

router.get("/profile", verifyToken, verifySeller, getSellerProfile);
router.get("/summary", verifyToken, verifySeller, getSellerSummary);
router.get("/performance", verifyToken, verifySeller, getSellerPerformance);
router.get(
  "/active-listings",
  verifyToken,
  verifySeller,
  getSellerActiveListings,
);
router.get("/recent-orders", verifyToken, verifySeller, getSellerRecentOrders);
router.get("/dashboard", verifyToken, verifySeller, getSellerDashboard);

router.post(
  "/become-seller",
  verifyToken,
  upload.fields([
    { name: "logo", maxCount: 1 },
    { name: "NICfront", maxCount: 1 },
    { name: "NICback", maxCount: 1 },
  ]),
  becomeSeller,
);

export default router;
