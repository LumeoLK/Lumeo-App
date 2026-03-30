import dotenv from "dotenv";
dotenv.config();
import { Worker } from "bullmq";
import Redis from "ioredis";
import axios from "axios";
import FormData from "form-data";
import { createMeshyTask } from "./services/meshyServices.js";

// Redis connection
const redisConnection = new Redis(process.env.REDIS_URL, {
  maxRetriesPerRequest: null,
  enableReadyCheck: false,
});

console.log("Worker is listening for jobs...");

// ----------------------------------------------------------------
//  WORKER 1 - Meshy AI queue
// ----------------------------------------------------------------
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

// ----------------------------------------------------------------
//  WORKER 2 - Blueprint 3D queue
// ----------------------------------------------------------------
const blueprintWorker = new Worker(
  "blueprint-3d-queue",
  async (job) => {
    const { jobId, blueprintUrl } = job.data;
    console.log(`Processing blueprint job ${jobId}`);

    try {
      const blueprintResponse = await axios.get(blueprintUrl, {
        responseType: "arraybuffer",
        timeout: 120000,
      });

      const blueprintBuffer = Buffer.from(blueprintResponse.data);
      const blueprintMimeType =
        blueprintResponse.headers["content-type"] || "image/png";

      const formData = new FormData();
      formData.append("file", blueprintBuffer, {
        filename: "blueprint.png",
        contentType: blueprintMimeType,
      });

      const response = await axios.post(
        `${process.env.PIPELINE_URL}/generate`,
        formData,
        {
          headers: formData.getHeaders(),
          responseType: "arraybuffer",
          timeout: 120000,
        },
      );

      const modelBuffer = Buffer.from(response.data);
      console.log(`ML done for job ${jobId} - ${modelBuffer.length} bytes`);

      await axios.post(
        `${process.env.BACKEND_URL}/api/webhooks/blueprint-3d-update`,
        {
          jobId,
          status: "completed",
          glbBase64: modelBuffer.toString("base64"),
          glbSize: modelBuffer.length,
        },
      );

      console.log(`Job ${jobId} complete - webhook sent`);
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
