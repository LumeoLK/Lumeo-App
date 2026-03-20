import express from "express";
import {
  handleMeshyWebhook,
  checkMeshyTaskStatus,
  updateMeshyTask,
  handleBlueprint3DWebhook,
} from "../controller/webhook.js";

const router = express.Router();

router.post("/meshy", handleMeshyWebhook);
router.post("/meshy-status", checkMeshyTaskStatus);
router.post("/meshy-update", updateMeshyTask);
router.post("/blueprint-3d-update", handleBlueprint3DWebhook);


export default router;
