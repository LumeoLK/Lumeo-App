import express from "express";
import { blueprint } from "../controller/blueprint3dController.js";

const router = express.Router();

router.post(
  "/create",
  upload.single("blueprint"),
  blueprint
);

export default router;