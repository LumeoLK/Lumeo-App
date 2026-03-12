import express from "express";
import { uploadBlueprint } from "../controller/blueprint3dController.js";
import upload from "../lib/cloudinary.js"
const router = express.Router();

router.post(
  "/create",
  upload.single("blueprint"),
  uploadBlueprint
);

export default router;