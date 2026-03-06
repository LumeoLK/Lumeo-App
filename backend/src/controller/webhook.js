import axios from "axios";
import Product from "../models/Product.js";
import { uploadToCloudinary } from "../lib/cloudinary.js"; 


export const handleMeshyWebhook = async (req, res) => {
  const incomingSecret = req.headers["x-meshy-api-webhook-secret-key"];
  const mySecret = process.env.MESHY_WEBHOOK_SECRET;
console.log("HI")
  if (incomingSecret !== mySecret) {
    console.error("SECURITY ALERT: Unauthorized webhook attempt!");
    return res.status(401).send("Unauthorized");
  }

  const payload = req.body;
  const meshyTaskId = payload.id;
  console.log(payload)
  try {
    const product = await Product.findOne({
      "model3D.meshyTaskId": meshyTaskId,
    });
    if (!product) {
      
      console.error(`Webhook Error: Product ${meshyTaskId} not found.`);
      return res.status(404).send("Product not found");
    }
    if (payload.status === "PENDING" || payload.status === "IN_PROGRESS") {
      console.log(
        `Meshy is working on product ${product._id}... Status: ${payload.status}`,
      );
      product.model3D.status = 'pending';
      await product.save();
      return res.status(200).send("Status Ignored");
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

      const temporaryGlbUrl = payload.model_urls.glb;


      const response = await axios.get(temporaryGlbUrl, {
        responseType: "arraybuffer",
      });
      const fileBuffer = Buffer.from(response.data);


      console.log("Uploading 3D model to Cloudinary...");
      const fileName = `product_${product._id}.glb`;

    
      const cloudinaryResult = await uploadToCloudinary(
        fileBuffer,
        "lumeo_3d_models",
        "raw",
        fileName,
      );

      // product.model3D.meshyTaskId=payload.id;
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

export const updateMeshyTask= async(req,res)=>{
  const { productId,meshyTaskId,status } = req.body;
  try {
    const product= await Product.findById(productId);
    if(!product){
      return res.status(404).send("Product not found");
    }
    product.model3D.meshyTaskId=meshyTaskId;
    product.model3D.status=status;
    await product.save();
    return res.status(200).send("Meshy Task ID updated successfully");
  } catch (error) {
    console.log(error.message)
    return res.status(500).send("Internal Server Error");
  }
}