import axios from "axios";
import FormData from "form-data";
import Product from "../models/Product.js";
import Seller from "../models/seller.js";
import { v2 as cloudinary } from "cloudinary";
import { generate3DModel } from "../services/meshyservices.js";
import { tryCatch } from "bullmq";
export const createProduct = async (req, res) => {
  try {
    const {
      title,
      description,
      price,
      category,
      stock,
      length,
      width,
      height,
    } = req.body;

    // 1. Authenticate Seller
    const seller = await Seller.findOne({ userId: req.user.id });
    if (!seller) {
      return res
        .status(404)
        .json({ success: false, msg: "Seller profile not found." });
    }

    // 2. File Validation
    if (!req.files || req.files.length === 0) {
      return res
        .status(400)
        .json({ success: false, msg: "Please upload at least one image." });
    }

    // We now know for a fact this contains our buffer!
    const mainImage = req.files[0];

    // 3. Process Upload & ML in Parallel
    const [mlResponse, cloudinaryResult] = await Promise.all([
      (async () => {
        const form = new FormData();
        form.append("file", mainImage.buffer, {
          filename: mainImage.originalname,
          contentType: mainImage.mimetype,
        });

        const mlUrl = process.env.ML_SERVICE_URL || "http://localhost:8000";
        return axios.post(`${mlUrl}/api/v1/product-metadata`, form, {
          headers: { ...form.getHeaders() },
        });
      })(),

      // Task B: Stream the Buffer straight to Cloudinary
      new Promise((resolve, reject) => {
        const stream = cloudinary.uploader.upload_stream(
          { folder: "lumeo_products" },
          (error, result) => (error ? reject(error) : resolve(result)),
        );
        stream.end(mainImage.buffer);
      }),
    ]);

    // 4. Extract Data from both successful tasks
    const { rgb, vector } = mlResponse.data.data;
    const finalCloudinaryUrl = cloudinaryResult.secure_url;

    // 5. Create Product
    const newProduct = new Product({
      sellerId: seller._id,
      title,
      description,
      price,
      category,
      stock,
      images: [finalCloudinaryUrl], // The actual URL from Task B
      dimensions: { length, width, height },
      dominantColor: rgb, // The AI data from Task A
      imageEmbedding: vector,
      model3D: { status: "pending" }
    });

    await newProduct.save();
    console.log("data saved")
    const result= await generate3DModel(newProduct._id, finalCloudinaryUrl); 

    res.status(201).json({
      success: true,
      msg: "Product created successfully!",
      product: newProduct,
      jobid: result.jobId,
    });
  } catch (error) {
    console.error("Product Creation Error:", error);
    res.status(500).json({ success: false, msg: error.message });
  }
};



export const handleMeshyWebhook = async (req, res) => {
  try {
    const { productId, model3DUrl } = req.body;
    const product = await Product.findById(productId);

    if (!product || product.model3D.status === "approved") {
      return res.status(200).json({ msg: "Already processed." });
    }

    const updated = await Product.findByIdAndUpdate(
      productId,
      {
        "model3D.url": model3DUrl,
        "model3D.status": "success",
      },
      { new: true },
    );

    if (!updated) {
      return res.status(404).json({ msg: "Product not found." });
    }

    console.log(`🎉 Product ${productId} successfully updated with 3D model!`);
    res.status(200).json({ msg: "Webhook received and database updated." });
  } catch (error) {
    console.error("Webhook Error:", error);
    res.status(500).json({ msg: "Failed to process webhook." });
  }
};

export const updateStatus = async (req, res) => {
  try {
    const { productId } = req.params;
    const { meshyTaskId,status} = req.body;
    const product = await Product.findById(productId);

    if (!product) {
      return res.status(404).json({ msg: "Product not found." });
    }
    if(meshyTaskId){
      await Product.findByIdAndUpdate(productId, {
        "model3D.meshyTaskId": meshyTaskId,
        "model3D.status": status,
      });
    }
    await Product.findByIdAndUpdate(productId, {
      "model3D.status": status,
    });
    
  } catch (error) {
    console.error("Error updating product status:", error);
    res.status(500).json({ msg: "Failed to update product status." });
  }
}

export const approve3DModel = async (req, res) => {
  try {
    const { productId } = req.params;
    const product = await Product.findById(productId);

    if (!product) {
      return res.status(404).json({ msg: "Product not found." });
    }

    if (product.model3D.status !== "success") {
      return res.status(400).json({ msg: "3D model is not ready for approval." });
    }

    await Product.findByIdAndUpdate(productId, {
      "model3D.status": "approved",
    });

    res.status(200).json({success:true, msg: "3D model approved successfully." });
  } catch (error) {
    console.error("Error approving 3D model:", error);
    res.status(500).json({ msg: "Failed to approve 3D model." });
  }
};