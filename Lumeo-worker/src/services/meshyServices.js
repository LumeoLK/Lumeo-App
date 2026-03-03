import axios from "axios";

const MESHY_API_KEY = process.env.MESHY_API_KEY;
console.log(MESHY_API_KEY)
const MESHY_BASE_URL = "https://api.meshy.ai/openapi/v1/multi-image-to-3d"; //

const getHeaders = () => ({
  Authorization: `Bearer ${process.env.MESHY_API_KEY}`,
  "Content-Type": "application/json",
});

/**
 * Step 1: Sends the image to Meshy and gets a Task ID
 */
export const createMeshyTask = async (imageUrl,productId) => {
  try {
    if (!process.env.MESHY_API_KEY) {
      throw new Error("MESHY_API_KEY is missing from environment variables");
    }
    const response = await axios.post(
      MESHY_BASE_URL,
      {
        image_url: imageUrl, //
        topology: "triangle",
        target_polycount: 30000,
        symmetry_mode: "auto",
        should_remesh: true,
        should_texture: true,
        enable_pbr: true,
        moderation: true,
        image_enhancement: false,
      },
      { headers: getHeaders() },
    );

    // Meshy returns the task ID in the 'result' field
    const result = await axios.post(
      `http://localhost:3000/api/products/webhook/meshy-success/${productId}`,
      {
        meshyTaskId: response.data.result,
        status: "generating",
      },
    );
    return response.data.result;
  } catch (error) {
    console.error(
      "Failed to create Meshy task:",
      error.response?.data || error.message,
    );
    throw new Error("Meshy Task Creation Failed");
  }
};

/**
 * Step 2: Polls the Meshy API every 10 seconds until the model is ready
 */
export const pollMeshyTask = async (taskId) => {
  return new Promise((resolve, reject) => {
    console.log(`⏳ Starting polling for Task ID: ${taskId}`);

    const intervalId = setInterval(async () => {
      try {
        const response = await axios.get(`${MESHY_BASE_URL}/${taskId}`, {
          headers,
        }); //
        const taskStatus = response.data.status; //
        const progress = response.data.progress; //

        console.log(`📊 Meshy Task Progress: ${progress}%`);

        if (taskStatus === "SUCCEEDED") {
          clearInterval(intervalId);
          const glbUrl = response.data.model_urls.glb;
          resolve(glbUrl);
        } else if (taskStatus === "FAILED" || taskStatus === "CANCELED") {
          clearInterval(intervalId);
          reject(
            new Error(
              response.data.task_error?.message || "Meshy task failed.",
            ),
          ); //
        }
        // If status is PENDING or IN_PROGRESS, the loop just continues
      } catch (error) {
        clearInterval(intervalId);
        reject(error);
      }
    }, 10000); // Poll every 10 seconds to avoid hitting rate limits
  });
};
