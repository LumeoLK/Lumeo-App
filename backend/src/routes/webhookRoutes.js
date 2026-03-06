import express from "express";
import {
  handleMeshyWebhook,
  checkMeshyTaskStatus,
  updateMeshyTask,
} from "../controller/webhook.js";

const router = express.Router();

router.post("/webhooks/meshy", handleMeshyWebhook);

router.post("/webhooks/meshy-status", checkMeshyTaskStatus);
router.post("/webhooks/meshy-update", updateMeshyTask);

export default router;
