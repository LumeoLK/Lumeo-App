import express from "express";
import { verifyToken } from "../middleware/auth.js";
import {
  startConversation,
  getConversations,
  sendMessage,
  getMessages,
} from "../controller/chatController.js";

const router = express.Router();

// All chat routes require login
router.post("/conversations", verifyToken, startConversation);
router.get("/conversations", verifyToken, getConversations);
router.post("/messages", verifyToken, sendMessage);
router.get("/messages/:conversationId", verifyToken, getMessages);

export default router;
