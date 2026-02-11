import express from 'express';
import { dashboardStat } from '../controller/adminController.js';

const router = express.Router();

// seller stats
router.get('/userStats', dashboardStat);

export default router;