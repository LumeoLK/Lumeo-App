import axios from "axios";


const MESHY_BASE_URL = "https://api.meshy.ai/openapi/v1/multi-image-to-3d"; 


const getHeaders = () => ({
  Authorization: `Bearer ${process.env.MESHY_API_KEY}`,
  "Content-Type": "application/json",
});

/**
 * Step 1: Sends the image to Meshy and gets a Task ID
 */
export const createMeshyTask = async (imageUrls, productId) => {
  try {
    if (!process.env.MESHY_API_KEY) {
      throw new Error("MESHY_API_KEY is missing from environment variables");
    }
    const imageArray = Array.isArray(imageUrls)
      ? imageUrls
      : imageUrls.split(",").map((url) => url.trim());

    const cleanedArray = imageArray.map((url) => url.replace(/^hhttp/, "http"));
   
    const response = await axios.post(
      MESHY_BASE_URL,
      {
        image_urls: cleanedArray,
        enable_pbr: true,
      },
      { headers: getHeaders() },
    );
    await axios.post(`${process.env.BACKEND_URL}/api/webhooks/meshy-update`, {
      productId,
      meshyTaskId: response.data.result,
      status: "generating",
    });
    console.log(response)
    return response.data.result;
  } catch (error) {
    console.error("Meshy Error Status:", error.response?.status);
    console.error("Meshy Error Data:", error.response?.data);
    console.error("Full Error:", error.message);
    throw new Error("Meshy Task Creation Failed");
  }
};




 