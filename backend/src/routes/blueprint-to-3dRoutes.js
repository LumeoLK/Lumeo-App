import express from "express";
import { uploadBlueprint } from "../controller/blueprint3dController.js";
import { getBlueprintJobStatus } from "../controller/blueprint3dController.js";
import upload from "../lib/cloudinary.js"
const router = express.Router();

router.post(
  "/create",
  upload.single("blueprint"),
  uploadBlueprint
);

router.get("/status/:jobId", getBlueprintJobStatus);

export default router;
