import dotenv from "dotenv";
dotenv.config();
import { Worker } from "bullmq";
import Redis from "ioredis";
import axios from "axios";
import { createMeshyTask } from "./services/meshyServices.js";

// Redis connection
const redisConnection = new Redis(process.env.REDIS_URL, {
  maxRetriesPerRequest: null,
  enableReadyCheck: false,
});

console.log("Worker is listening for jobs...");

const meshyWorker = new Worker(
  "meshy-3d-queue",
  async (job) => {
    console.log(`Processing Product ID: ${job.data.productId}`);
    console.log(`Image URL: ${job.data.imageUrl}`);

    try {
      const taskId = await createMeshyTask(
        job.data.imageUrl,
        job.data.productId,
      );
      console.log(`Meshy Task Created: ${taskId}`);
      console.log(
        `Meshy task added for ${job.data.productId} successfully, waiting for webhook...`,
      );
      return { status: "success", taskId };
    } catch (error) {
      console.error(`Meshy job failed:`, error.message);
      throw error;
    }
  },
  { connection: redisConnection, concurrency: 4 },
);

meshyWorker.on("failed", async (job, err) => {
  console.error(`Meshy job ${job.id} failed: ${err.message}`);

  if (job.attemptsMade === job.opts.attempts) {
    try {
      await axios.post(
        `${process.env.BACKEND_URL}/api/products/webhook/meshy-update`,
        {
          meshyTaskId: "",
          status: "failed",
        },
      );
    } catch (webhookError) {
      console.error("Failed to notify backend:", webhookError.message);
    }
  }
});

// ────────────────────────────────────────────────────────
//  WORKER 2 — Blueprint 3D queue
// ────────────────────────────────────────────────────────
const blueprintWorker = new Worker(
  "blueprint-3d-queue",
  async (job) => {
    const { jobId, blueprintUrl } = job.data;
    console.log(`Processing blueprint job ${jobId}`);

    try {
      // 1. Call Python ML service — get GLB bytes back
      // const response = await axios.post(
      //   `${process.env.ML_SERVICE_URL}/generate-3d`,
      //   { imageUrl: blueprintUrl },
      //   { responseType: "arraybuffer", timeout: 120000 }
      // );

      // const modelBuffer = Buffer.from(response.data);
      // console.log(`ML done for job ${jobId} — ${modelBuffer.length} bytes`);

      // Replace the ML service URL with your static test model URL
      const SIMULATED_ML_URL =
        "https://res.cloudinary.com/drno34my4/raw/upload/v1773127388/lumeo_3d_models/product_69afc5c3027d16efd3341435.glb";

      console.log(`Simulating ML generation for job ${jobId}...`);

      // We perform a GET request to the static link instead of a POST to the ML service
      const response = await axios.get(SIMULATED_ML_URL, {
        responseType: "arraybuffer",
        timeout: 120000,
      });

      const modelBuffer = Buffer.from(response.data);
      console.log(
        `Simulation done for job ${jobId} — ${modelBuffer.length} bytes`,
      );

      // The rest of your code remains the same...
      // Main backend handles Cloudinary upload + DB update
      await axios.post(
        `${process.env.BACKEND_URL}/api/webhooks/blueprint-3d-update`, // fix the links after tesdting
        {
          jobId,
          status: "completed",
          glbBase64: modelBuffer.toString("base64"),
          glbSize: modelBuffer.length,
        },
      );

      console.log(`Job ${jobId} complete — webhook sent`);
      return { success: true };
    } catch (error) {
      console.error(`Blueprint worker error for job ${jobId}:`, error.message);

      await axios
        .post(`${process.env.BACKEND_URL}/api/webhooks/blueprint-3d-update`, {
          jobId,
          status: "failed",
          errorMessage: error.message,
        })
        .catch((e) => console.error("Webhook notify error:", e.message));

      throw error;
    }
  },
  { connection: redisConnection, concurrency: 3 },
);

blueprintWorker.on("failed", async (job, err) => {
  console.error(`Blueprint job ${job.data?.jobId} failed: ${err.message}`);

  if (job.attemptsMade === job.opts.attempts) {
    await axios
      .post(`${process.env.BACKEND_URL}/api/webhooks/blueprint-3d-update`, {
        jobId: job.data.jobId,

        status: "failed",
        errorMessage: err.message,
      })
      .catch((e) => console.error("Webhook notify error:", e.message));
  }
});
