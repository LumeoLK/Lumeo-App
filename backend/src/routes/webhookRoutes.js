import express from "express";
import {
  handleMeshyWebhook,
  checkMeshyTaskStatus,
  updateMeshyTask,
  handleBlueprint3DWebhook,
} from "../controller/webhook.js";

const router = express.Router();

router.post("/webhooks/meshy", handleMeshyWebhook);
router.post("/webhooks/meshy-status", checkMeshyTaskStatus);
router.post("/webhooks/meshy-update", updateMeshyTask);
router.post("/webhooks/blueprint-3d-update", handleBlueprint3DWebhook);


export default router;
