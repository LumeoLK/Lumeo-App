
import dotenv from "dotenv";
dotenv.config();
import { Worker } from "bullmq";
import Redis from "ioredis";
import axios from "axios";
import { createMeshyTask, pollMeshyTask } from "./services/meshyServices.js"; 

const redisConnection = new Redis(process.env.REDIS_URL, {
  maxRetriesPerRequest: null,
  enableReadyCheck: false,
});

console.log("👷 Lumeo Meshy Worker is listening for jobs...");

const worker = new Worker(
  "meshy-3d-queue",
  async (job) => {
    console.log(`\n📦 Processing Product ID: ${job.data.productId}`);
    console.log(`🖼️ Image URL: ${job.data.imageUrl}`);

    try {
      // 1. Send image to Meshy AI
      const taskId = await createMeshyTask(
        job.data.imageUrl,
        job.data.productId,
      );
      console.log(`Meshy Task Created! ID: ${taskId}`);

      // 2. Wait for Meshy to finish generating the 3D model
      // const generatedModelUrl = await pollMeshyTask(taskId);
      // console.log(`🎉 3D Model Generated! URL: ${generatedModelUrl}`);

      // 3. The Webhook: Send the result BACK to the Main Backend
      // await axios.post(
      //   "http://localhost:3000/api/products/webhook/meshy-success",
      //   {
      //     productId: job.data.productId,
      //     model3DUrl: generatedModelUrl,
      //   },
      // );
      console.log(
        `meshy task added for ${job.data.productId} successfully, waiting for webhook to update the product with the 3D model URL...`,
      );

      return { status: "success", modelUrl: generatedModelUrl };
    } catch (error) {
      console.error(`Job Failed:`, error.message);
      throw error; // Let BullMQ handle the retry logic
    }
  },
  { connection: redisConnection, concurrency: 5 },
);


//failure listener to catch errors after all retries are exhausted
worker.on("failed", async (job, err) => {
  console.error(`Job ${job.id} failed: ${err.message}`);

  if (job.attemptsMade === job.opts.attempts) {
    try {
      await axios.post(
        `${process.env.BACKEND_URL}/api/products/webhook/meshy-success/${job.data.productId}`,
        {
          meshyTaskId: null,
          status: "failed",
        },
      );
    } catch (webhookError) {
      console.error(
        "Failed to notify backend of permanent failure:",
        webhookError.message,
      );
    }
  }
});
