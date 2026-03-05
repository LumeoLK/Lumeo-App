import axios from "axios";


const MESHY_BASE_URL = "https://api.meshy.ai/openapi/v1/multi-image-to-3d"; //

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

    // 2. Fix the typo in the third URL if it exists (your log showed "hhttps")
    const cleanedArray = imageArray.map((url) => url.replace(/^hhttp/, "http"));
    const webhookUrl = `${process.env.BACKEND_URL}/api/webhooks/meshy?productId=${productId}`;
    console.log(webhookUrl)
    // const response = await axios.post(
    //   MESHY_BASE_URL,
    //   {
    //     image_urls: cleanedArray, 
    //     enable_pbr: true,
    //     webhook_url: webhookUrl,
    //   },
    //   { headers: getHeaders() },
    // );
    // console.log(response)
    // return response.data.result;
  } catch (error) {
    console.error(
      "Failed to create Meshy task:",
      error.response?.data || error.message,
    );
    throw new Error("Meshy Task Creation Failed");
  }
};


