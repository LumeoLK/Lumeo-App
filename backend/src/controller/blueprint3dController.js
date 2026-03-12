import Blueprint3DJob from "../models/Blueprint3DJob.js";
import { uploadToCloudinary } from "../lib/cloudinary.js";
import { blueprint3DQueue } from "../lib/queue.js";

export const uploadBlueprint = async (req, res) => {
  try {
    
    if (!req.file) {
      return res.status(400).json({
        message: "Blueprint image is required",
      });
    }

    // Upload blueprint image
    const cloudinaryResult = await uploadToCloudinary(
      req.file.buffer,
      "blueprints",
      "image"
    );

    const blueprintUrl = cloudinaryResult.secure_url;
    console.log(blueprintUrl)
    // Save job in DB
    const job = await Blueprint3DJob.create({
      blueprintImageUrl: blueprintUrl,
      status: "pending",
    });

    // Add job to queue
    const queueJob = await blueprint3DQueue.add("generate-3d-from-blueprint", {
      jobId: job._id,
      blueprintUrl,
    });

    // Save queue id
    job.queueJobId = queueJob.id;
    job.status = "processing";
    await job.save();

    res.status(200).json({
      success: true,
      message: "3D generation started",
      jobId: job._id,
    });
  } catch (error) {
    console.error(error);

    res.status(500).json({
      message: "Failed to start generation",
    });
  }
};