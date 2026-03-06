import axios from "axios";
import Product from "../models/Product.js";
import { uploadToCloudinary } from "../lib/cloudinary.js"; 
import crypto from "crypto";

export const handleMeshyWebhook = async (req, res) => {
  console.log("🕵️ INCOMING HEADERS:", req.headers);
  const meshySignature = req.headers["x-meshy-signature"]; 
  const webhookSecret = process.env.MESHY_WEBHOOK_SECRET;

  if (meshySignature && webhookSecret) {

    const generatedSignature = crypto
      .createHmac("sha256", webhookSecret)
      .update(JSON.stringify(req.body))
      .digest("hex");

    if (generatedSignature !== meshySignature) {
      console.error("🚨 SECURITY ALERT: Invalid Webhook Signature!");
      return res.status(401).send("Unauthorized");
    }
    console.log("🔐 Webhook signature verified successfully.");
  } else {
    console.warn(
      "Warning: No signature or secret provided, bypassing security check.",
    );
  }

  const payload = req.body;
    console.log(payload)
    console.log(productId)
  try {
    // 2. Find the product in the database
    const product = await Product.findById(productId);
    if (!product) {
      console.error(`Webhook Error: Product ${productId} not found.`);
      return res.status(404).send("Product not found");
    }

    // 3. Handle a FAILED generation
    if (payload.status === "FAILED" || payload.status === "CANCELED") {
      console.error("Meshy Task Failed:", payload.task_error?.message);
      product.model3D.status = "failed";
      product.model3D.message =
        payload.task_error?.message || "Unknown Meshy Error";
      await product.save();

      return res.status(200).send("Acknowledged Failure"); 
    }

    // 4. Handle a SUCCESSFUL generation
    if (payload.status === "SUCCEEDED") {
      console.log(`Meshy succeeded for Product ${productId}. Downloading GLB...`,);

      const temporaryGlbUrl = payload.model_urls.glb;

        // Download the GLB file as a buffer
      const response = await axios.get(temporaryGlbUrl, {
        responseType: "arraybuffer",
      });
      const fileBuffer = Buffer.from(response.data);


      console.log("Uploading 3D model to Cloudinary...");
      const cloudinaryResult = await uploadToCloudinary(
        fileBuffer,
        "lumeo_3d_models",
        "raw",
      );

      product.model3D.meshyTaskId=payload.id;
      product.model3D.url = cloudinaryResult.secure_url;
      product.model3D.status = "success";
      await product.save();

      console.log(
        `3D Model permanently saved: ${cloudinaryResult.secure_url}`,
      );
      return res.status(200).send("Webhook Processed Successfully");
    }

    return res.status(200).send("Status Ignored");
  } catch (error) {
    console.error("Webhook Processing Error:", error);
    return res.status(500).send("Internal Server Error");
  }
};

export const checkMeshyTaskStatus = async (req, res) => {
  const { meshyTaskId } = req.body;

  try {
    const response = await axios.get(
      `https://api.meshy.ai/openapi/v1/multi-image-to-3d/${meshyTaskId}`,
      {
        headers: {
          Authorization: `Bearer ${process.env.MESHY_API_KEY}`,
        },
      },
    );
    console.log("hi")
    console.log(response.data)
    return res.status(200).json(response.data);
  } catch (error) {
    console.error("Error checking Meshy task status:", error);
    return res.status(500).send("Internal Server Error");
  }
};
