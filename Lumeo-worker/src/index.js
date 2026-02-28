import { Worker } from "bullmq";
import Redis from "ioredis";
import axios from "axios";
import dotenv from "dotenv";
// import { createMeshyTask, pollMeshyTask } from "./services/meshy.service.js"; // Import the new service
import { runMeshyProcess } from "./services/testAPI.js"; // For testing purposes
dotenv.config();

const redisConnection = new Redis(process.env.REDIS_URL, {
  maxRetriesPerRequest: null,
  enableReadyCheck: false,
});

console.log("👷 Lumeo Meshy Worker is listening for jobs...");
const testResult = await runMeshyProcess(); // Run the test function to verify Meshy integration (optional)
console.log("🧪 Test Result:", testResult);
const worker = new Worker(
  "meshy-3d-queue",
  async (job) => {
    console.log(`\n📦 Processing Product ID: ${job.data.productId}`);
    console.log(`🖼️ Image URL: ${job.data.imageUrl}`);

    try {
      // 1. Send image to Meshy AI
      const taskId = await createMeshyTask(job.data.imageUrl);
      console.log(`✅ Meshy Task Created! ID: ${taskId}`);

      // 2. Wait for Meshy to finish generating the 3D model
      const generatedModelUrl = await pollMeshyTask(taskId);
      console.log(`🎉 3D Model Generated! URL: ${generatedModelUrl}`);

      // 3. The Webhook: Send the result BACK to the Main Backend
      await axios.post(
        "http://localhost:5000/api/products/webhook/meshy-success",
        {
          productId: job.data.productId,
          model3DUrl: generatedModelUrl,
        },
      );
      console.log(
        `✅ Webhook sent successfully for Product ${job.data.productId}`,
      );

      return { status: "success", modelUrl: generatedModelUrl };
    } catch (error) {
      console.error(`❌ Job Failed:`, error.message);
      throw error; // Let BullMQ handle the retry logic
    }
  },
  { connection: redisConnection },
);
