import express from "express";
import { handleMeshyWebhook,checkMeshyTaskStatus } from "../controller/webhook.js";

const router = express.Router();

router.post("/webhooks/meshy", handleMeshyWebhook);

router.post("/webhooks/meshy-status", checkMeshyTaskStatus);

export default router;
