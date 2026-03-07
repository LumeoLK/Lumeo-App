import Product from "../models/Product.js";
import {meshyQueue} from "../lib/queue.js"; 

export const generate3DModel = async (productId, imageUrl) => {
  try {
    if (!productId || !imageUrl) {
      return res
        .status(400)
        .json({ msg: "Product ID and Image URL are required." });
    }
    const product = await Product.findById(productId);
    if (!product) {
      return res.status(404).json({ msg: "Product not found." });
    }
    // Add the Job to the Redis Queue
    const job = await meshyQueue.add("generate-3d", {
      productId: productId,
      imageUrl: imageUrl,
    });
    return {
      msg: "3D Generation started successfully!",
      jobId: job.id,
      status: "pending",
    }
  } catch (error) {
    console.error("Queue Error:", error);
    return({msg:"Failed to start 3D generation."});
  }
};

