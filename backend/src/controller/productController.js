import axios from "axios";
import FormData from "form-data";
import Product from "../models/Product.js";
import Seller from "../models/seller.js";

export const createProduct = async (req, res) => {
  try {
    const { title, description, price, category, stock, length, width, height } = req.body;

    // 1. Authenticate Seller (Your code)
    const seller = await Seller.findOne({ userId: req.user.id });
    if (!seller) {
      return res.status(404).json({ success: false, msg: "Seller profile not found." });
    }

    // 2. Check for uploaded files (Your code)
    if (!req.files || req.files.length === 0) {
      return res.status(400).json({ success: false, msg: "Please upload at least one image." });
    }

    // 3. Get Cloudinary URLs from your middleware
    const imageUrls = req.files.map((file) => file.path);
    const mainImageUrl = imageUrls[0]; // We'll send the first image to the AI

    // 4. ML Integration (Adapted ML Engineer code)
    // Since we don't have a buffer from Multer, we fetch the image from Cloudinary to create one
    const imageResponse = await axios.get(mainImageUrl, { responseType: "arraybuffer" });
    const imageBuffer = Buffer.from(imageResponse.data, "binary");

    const form = new FormData();
    form.append("file", imageBuffer, {
      filename: "main_image.jpg", 
      contentType: imageResponse.headers["content-type"] || "image/jpeg",
    });

    // Call AI Service
    const mlUrl = process.env.ML_SERVICE_URL || "http://localhost:8000";
    const mlResponse = await axios.post(`${mlUrl}/api/v1/product-metadata`, form, {
      headers: { ...form.getHeaders() },
    });

    // Extract AI Data
    const { rgb, vector } = mlResponse.data.data;

    // 5. Create Product (Merged logic)
    const newProduct = new Product({
      sellerId: seller._id,
      title,
      description,
      price,
      category,
      stock,
      images: imageUrls,
      dimensions: { length, width, height }, // Your dimensions logic
      dominantColor: rgb,                      // ML Engineer's AI data
      imageEmbedding: vector,                  // ML Engineer's AI data
    });

    await newProduct.save();

    res.status(201).json({ 
      success: true, 
      msg: "Product created successfully!", 
      product: newProduct 
    });

  } catch (error) {
    console.error("Product Creation Error:", error);
    res.status(500).json({ success: false, msg: error.message });
  }
};