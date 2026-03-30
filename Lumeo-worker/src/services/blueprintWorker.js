import dotenv from "dotenv";
dotenv.config();

import { Worker } from "bullmq";
import Redis from "ioredis";
import axios from "axios";
import FormData from "form-data";
import { uploadToCloudinary } from "./cloudinary.js";

const redisConnection = new Redis(process.env.REDIS_URL, {
  maxRetriesPerRequest: null,
  enableReadyCheck: false,
});

console.log("Blueprint Worker listening...");

const worker = new Worker(
  "blueprint-3d-queue",
  async (job) => {
    console.log(`Processing blueprint job ${job.data.jobId}`);

    try {
      const blueprintResponse = await axios.get(job.data.blueprintUrl, {
        responseType: "arraybuffer",
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
        },
      );

      const modelBuffer = Buffer.from(response.data);

      const cloudinaryResult = await uploadToCloudinary(
        modelBuffer,
        "3d-models",
        "auto",
        `model_${job.data.productId}`,
      );

      await axios.post(
        `${process.env.MAIN_BACKEND_URL}/api/webhooks/blueprint-3d-update`,
        {
          jobId: job.data.jobId,
          productId: job.data.productId,
          model3DUrl: cloudinaryResult.secure_url,
          status: "completed",
        },
      );

      console.log(
        `3D model generated and webhook sent successfully for job ${job.data.jobId}`,
      );
      return { success: true };
    } catch (error) {
      console.error(`Worker error for job ${job.data.jobId}:`, error.message);

      await axios
        .post(
          `${process.env.MAIN_BACKEND_URL}/api/webhooks/blueprint-3d-update`,
          {
            jobId: job.data.jobId,
            productId: job.data.productId,
            status: "failed",
            errorMessage: error.message,
          },
        )
        .catch((err) => console.error("Webhook failure:", err.message));

      throw error;
    }
  },
  {
    connection: redisConnection,
    concurrency: 3,
  },
);
