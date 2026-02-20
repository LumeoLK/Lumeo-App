import axios from "axios";
import FormData from "form-data";
import Product from "../models/Product.js";
import { v2 as cloudinary } from "cloudinary";

export const processNewProduct = async (req, res) => {
  try {
    // Check if files exist
    const files = req.files;
    if (!files || files.length === 0) {
      return res.status(400).json({ message: "No images provided" });
    }

    const mainImage = files[0];

    // Call AI and Upload to Cloudinary simultaneously
    const [mlResponse, cloudinaryResult] = await Promise.all([
      // Call AI Service
      (async () => {
        const form = new FormData();

        if (!mainImage.buffer) throw new Error("File buffer is empty");

        form.append("file", mainImage.buffer, {
          filename: mainImage.originalname,
          contentType: mainImage.mimetype,
        });

        const mlUrl = process.env.ML_SERVICE_URL || "http://localhost:8000";
        return axios.post(`${mlUrl}/api/v1/product-metadata`, form, {
          headers: { ...form.getHeaders() },
        });
      })(),

      // Upload to Cloudinary
      new Promise((resolve, reject) => {
        const stream = cloudinary.uploader.upload_stream(
          { folder: "lumeo_products" },
          (error, result) => (error ? reject(error) : resolve(result)),
        );
        stream.end(mainImage.buffer);
      }),
    ]);

    // Extract AI Data
    const { rgb, vector } = mlResponse.data.data;

    //Create Product
    const newProduct = new Product({
      ...req.body,
      // Safety check for dimensions parsing
      dimensions:
        typeof req.body.dimensions === "string"
          ? JSON.parse(req.body.dimensions)
          : req.body.dimensions,
      images: [cloudinaryResult.secure_url],
      dominantColor: rgb,
      imageEmbedding: vector,
    });

    await newProduct.save();

    res.status(201).json({
      success: true,
      product: newProduct,
    });
  } catch (error) {
    console.error("Pipeline Error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};
