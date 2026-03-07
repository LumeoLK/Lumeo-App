import axios from "axios";
import dotenv from "dotenv";

dotenv.config();

const API_KEY = process.env.TEST_KEY;
const BASE_URL = "https://api.meshy.ai/openapi/v2/text-to-3d";

// Every request to Meshy MUST have this header
const headers = {
  Authorization: `Bearer ${API_KEY}`,
};

export const runMeshyProcess = async () => {
  try {
    // --- STEP 1: CREATE THE TASK ---
    console.log("📤 Sending image to Meshy...");
    const createResponse = await axios.post(
      BASE_URL,
      { mode: "preview", prompt: "A simple 3D model of a house", enable_pbr: true },
      { headers },
    );

    // Meshy gives us a 'result' which is just a string (the Task ID)
    const taskId = createResponse.data.result;
    console.log(`✅ Task Created! ID: ${taskId}`);

    // --- STEP 2: THE POLLING LOOP ---
    // We stay in this loop until Meshy is finished
    let isFinished = false;
    let modelUrl = "";

    while (!isFinished) {
      console.log("⏳ Checking status...");

      // Wait for 5 seconds before asking again (to avoid spamming the API)
      await new Promise((resolve) => setTimeout(resolve, 5000));

      const statusResponse = await axios.get(`${BASE_URL}/${taskId}`, {
        headers,
      });
      const task = statusResponse.data;

      console.log(`📊 Progress: ${task.progress}% | Status: ${task.status}`);

      if (task.status === "SUCCEEDED") {
        console.log(task);
        modelUrl = task.model_urls.glb; // This is the 3D file for Unity
        isFinished = true;
      } else if (task.status === "FAILED") {
        throw new Error("Meshy AI failed to generate the model.");
      }
    }
    console.log(`🎉 3D Model is ready! Download it here: ${modelUrl}`);
    return modelUrl;
  } catch (error) {
    console.error("Meshy Error:", error.response?.data || error.message);
    throw error;
  }
};
