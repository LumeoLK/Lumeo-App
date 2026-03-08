import express from "express";
import { blueprint } from "../controller/blueprint3dController";

const router = express.Router();

router.post("/create",blueprint);

export default router;