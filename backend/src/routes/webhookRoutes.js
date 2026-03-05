import express from "express";
import { handleMeshyWebhook } from "../controller/webhook.js";

const router = express.Router();

router.post("/webhooks/meshy", handleMeshyWebhook);

export default router;
