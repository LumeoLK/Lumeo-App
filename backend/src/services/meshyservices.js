import Product from "../models/Product.js";

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
    // 1. Update the product status in MongoDB to show it's working
    await Product.findByIdAndUpdate(productId, {
      "model3D.status": "generating", // We will need to add this status field to your model later
    });

    // 2. Add the Job to the Redis Queue!
    // We pass the data the Worker will need: the image to process, and the product ID to update later.
    const job = await meshyQueue.add("generate-3d", {
      productId: productId,
      imageUrl: imageUrl,
    });
    console.log("generate3DModel - Job added to queue with ID:", job.id);
    // 3. Immediately respond to the Flutter app (Do not wait for Meshy!)
    res.status(200).json({
      msg: "3D Generation started successfully!",
      jobId: job.id,
      status: "pending",
    });
  } catch (error) {
    console.error("Queue Error:", error);
    res.status(500).json({ msg: "Failed to start 3D generation." });
  }
};
