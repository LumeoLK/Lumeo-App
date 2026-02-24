import dotenv from "dotenv";
dotenv.config();

import { Worker } from "bullmq";
import Redis from "ioredis";
import axios from "axios";

const redisConnection = new Redis(process.env.REDIS_URL, {
  maxRetriesPerRequest: null,
  enableReadyCheck: false,
});

console.log("👷 Lumeo Meshy Worker is listening for jobs...");

const worker = new Worker("meshy-3d-queue", async (job) => {
    console.log(`\n📦 Processing Product ID: ${job.data.productId}`);
    
    // 1. Simulate Meshy AI Generation (Takes 5 seconds)
    await new Promise(resolve => setTimeout(resolve, 5000));
    const generatedModelUrl = "https://mock-s3-url.com/model.glb"; 
    
    // 2. The Webhook: Send the result BACK to the Main Backend
    try {
        // Change localhost to your Render URL later for production
        await axios.post("http://localhost:5000/api/products/webhook/meshy-success", {
            productId: job.data.productId,
            model3DUrl: generatedModelUrl
        });
        console.log(`✅ Webhook sent successfully for Job ${job.id}`);
    } catch (error) {
        console.error(`❌ Failed to send webhook:`, error.message);
        throw error; // This tells BullMQ the job failed so it can retry
    }

    return { status: "success" };
}, { connection: redisConnection });